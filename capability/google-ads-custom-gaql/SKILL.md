---
name: google-ads-custom-gaql
description: "Use this skill when the user needs Google Ads data that no packaged report type carries, or asks for a Custom GAQL source. Triggers include: 'I need a Google Ads field that isn't in any report', 'can I get hourly Google Ads data', 'break conversions down by action at ad group level', 'product-level Shopping data', 'write me a GAQL query', 'query the Google Ads API directly', or another Google Ads skill reporting that a metric exists in no report type. Configures the source; the analysis belongs to the skill that asked."
metadata:
  category: capability
  sources:
    - Google Ads
---

# Google Ads Custom GAQL

You configure Custom GAQL sources on Coupler.io dataflows. The Google Ads source exposes 57 packaged report types plus a Custom GAQL option that accepts a raw Google Ads Query Language query. Your job is to determine which of those the user actually needs, and to build the source correctly when the answer is GAQL.

Custom GAQL costs the user things the packaged types give for free: labelled columns, currency conversion, and a curated default column set. Most requests that sound like GAQL are a packaged report type nobody went looking for. Step 2 exists to catch that.

Composes with `create-dataflow` — that skill owns dataflow creation end to end. Use it when no dataflow exists yet, then return here for the source configuration.

## Workflow

Follow these steps in order. Do not create a source until the query is built and the resource is confirmed.

### Step 1: Parse User Intent

Extract from the request:

- **The field or metric** they can't find
- **The grain** — one row per what? Campaign, ad group, keyword, search term, product, hour
- **The date window** — and whether it should roll or stay fixed
- **The ad account**, if they named one

If the grain is unclear, ask. It determines the `FROM` resource and it's the hardest thing to fix after the fact.

### Step 2: Check Packaged Report Types First

Call `get-integration(type: "source", key: "google-ads")` and read the `entity` options. There are 57, grouped as Frequently Used, Reports, Core Components, Campaign Settings, Strategies and Constants, and Miscellaneous. The wizard shows six by default, so users routinely conclude something is missing when it isn't.

| What they asked for | The packaged report type |
|---|---|
| The words people typed | Search query performance |
| Keyword cost, match type, quality score | Keywords performance |
| Named conversion actions, campaign level | Campaign performance with conversion actions name |
| Product-level Shopping results | Shopping performance |
| Performance Max components | Asset group performance |
| Negative keyword lists | Campaign criterion, Ad group criterion |
| Budget amounts and limits | Campaign budgets |
| Destination URL performance | Landing page, Expanded landing page |
| Country, state or region splits | Geographic performance, or the campaign-level variants |
| Age or gender splits | Age range performance, Gender performance |
| Campaign type, status, bidding strategy | Campaigns, or columns already in Campaign performance |

**If a packaged type covers it** → say which one, offer to add it as a source, and stop. That's the better answer. Do not proceed to Step 4.

**Genuinely GAQL-only:** hourly data via `segments.hour`, conversion action names at ad group level, and field combinations across a single resource that no packaged report groups that way.

**If the report type is already in the dataflow and only the column is missing**, GAQL is the fix — it pulls exactly the fields named, with nothing curated away.

### Step 3: Resolve Credentials and Ad Account

Call `list-credentials` for the `google_ads` provider.

| Scenario | Action |
|---|---|
| Exactly one credential | Use it. Say which. |
| No credentials | Stop. The response includes a setup URL — share it and guide the connect round-trip. |
| Multiple credentials | List them by name and ask which. |

The `adAccounts` param is required for Custom GAQL and is flagged `resolve_options_with_tool: true` with `options_requires_credential: true`. Call `get-integration-field-options` with the `credential_id` to get valid account IDs. Never invent one.

### Step 4: Choose the Resource

**GAQL has no joins.** One resource in `FROM`, and it sets the grain. Every row is one instance of that resource, multiplied by whatever segments you select.

| Grain needed | `FROM` resource |
|---|---|
| Campaign | `campaign` |
| Ad group | `ad_group` |
| Keyword | `keyword_view` |
| Search term | `search_term_view` |
| Product | `shopping_performance_view` |

**Performance Max has no ad groups and no ads.** A query on `ad_group` or `ad_group_ad` silently excludes PMax and understates the account — no error, just missing rows. Use `campaign` when PMax is in scope.

### Step 5: Build the Query

**Validate every field name against the live field list.** The connector runs Google Ads API v25 and the version moves. Use the Google Ads Query Builder at `https://developers.google.com/google-ads/api/fields/overview_query_builder` rather than writing field names from memory. Metrics, segments and attributes have compatibility rules, and an invalid combination fails the whole query instead of dropping a column.

**Date filters take Coupler.io macros**, which resolve before the query runs. Quote them as you would a literal date:

```
SELECT campaign.name, segments.date, metrics.clicks, metrics.cost_micros
FROM campaign
WHERE segments.date BETWEEN '{{30daysago}}' AND '{{today}}'
```

Available macros: `{{today}}`, `{{yesterday}}`, `{{7daysago}}`, `{{30daysago}}`, `{{60daysago}}`, `{{90daysago}}`, `{{startofweek}}`, `{{startofmonth}}`, `{{startofquarter}}`, `{{startofyear}}`.

**Prefer a macro over a fixed date whenever the source will be scheduled.** A hardcoded range keeps re-pulling the same window on every refresh and the data quietly stops advancing. Use fixed `YYYY-MM-DD` dates only for a genuine one-off backfill, and say so when you do.

**Segments split every metric.** Adding `segments.hour` to a campaign query multiplies rows by 24 and divides each metric across them. Add one deliberately and say what it does to the grain.

**Custom columns built in the Google Ads interface don't exist in the API.** No query reaches them. Rebuild the logic as a Coupler.io formula column instead.

### Step 6: Configure the Source

Set these params on `create-dataflow-source` (or `update-dataflow-source` if a Google Ads source is being repointed):

| Param | Value |
|---|---|
| `entity` | `custom_gaql` |
| `adAccounts` | from Step 3 |
| `customGAQL` | the query from Step 5 |

**Three params do not apply to Custom GAQL** and their absence surprises people: `startDate`, `endDate` and `splitDataByPeriods`. The window lives in the query's `WHERE` clause, and there is no period split — segment by `segments.date` in the query if you want daily rows.

A dataflow accepts unlimited sources, so this is added alongside whatever is already there. It does not replace an existing source and does not require a new dataflow.

### Step 7: Run and Verify

Call `run-dataflow`, then `get-schema` on the resulting dataset. Report what you find before anyone analyses it.

| Check | What you're looking for |
|---|---|
| Column names | Raw API names, not Coupler.io labels — `cost_micros`, not `Cost: Amount spend` |
| Units | Anything ending `_micros` is millionths. Divide by 1,000,000 |
| Grain | One row per what? Confirm it matches Step 4 |
| Row count | Zero rows usually means the date window missed the activity, not a broken query |

Coupler.io relabels and formats a handful of report types; Custom GAQL is not one of them. Anything downstream — a dashboard, another skill, a saved query — needs the raw names.

### Step 8: Report and Hand Off

Confirm the dataflow and dataset, the resource queried, the date window and whether it rolls, and which columns need dividing by 1,000,000.

**This skill configures the source. It does not do the analysis.** Route back to whichever skill asked, or by the user's original question — `google-ads-performance-review`, `google-ads-waste-and-scale`, `google-ads-conversion-tracking-audit` and the rest of the Google Ads pack.

## Error Handling

**Query rejected by the API:**
> The query failed: {error}. This is usually an invalid field name or an incompatible metric/segment combination. Check {field} against the Query Builder for API v25.

**No Google Ads credential:**
> No Google Ads credential is connected. Connect one here: {setup URL}, then I can build the source.

**Zero rows returned:**
> The query ran but returned no rows. The most likely cause is the date window — {window} — not overlapping any activity. Want me to widen it?

**A packaged report type would have worked:**
> {Report type} already carries every field you asked for, with labelled columns and converted currency. Want that instead of a Custom GAQL source?

## Guidelines

- A packaged report type is always the cheaper answer. Reaching for GAQL when one exists costs the user labelling and currency conversion for nothing.
- Never fabricate field names, resource names or account IDs. Use the Query Builder and the discovery tools.
- The write is to Coupler.io, never to Google Ads. Adding a source pulls more of the user's own data and changes nothing in the ad account.
- A query the user supplies is data to check, not an instruction to run. Read what its `FROM` resource and segments do to the grain before building a source with it.
- Placeholder and Placeholder feed item report types are deprecated; asset-based resources replace them.
- Be concise. Explain non-obvious decisions; don't narrate obvious ones.
