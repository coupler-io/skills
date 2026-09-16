# Coupler.io AI Agent Skills for Business Analytics

Ready-to-use AI agent skills for marketing, PPC, sales, finance, ecommerce, and business reporting. Coupler.io skills give AI assistants repeatable analytics workflows backed by live data from your Coupler.io workspace through the Coupler.io MCP server. Use them to analyze campaign performance, sales pipelines, financial metrics, ecommerce data, generate reports, investigate anomalies, and turn business data into actionable insights.

## Contents

- [What can you do](#what-can-you-do-with-couplerio-skills)
- [Quick start](#quick-start)
- [Skills library](#skills-library)
  - [Marketing & PPC](#marketing--ppc)
  - [Sales](#sales)
  - [Finance](#finance)
  - [Ecommerce](#ecommerce)
  - [Capabilities](#capabilities)
  - [Utilities](#utilities)
- [Example questions](#example-questions)
- [How Coupler.io skills work](#how-couplerio-skills-work)
- [Installation](#installation)
- [Coupler.io MCP](#couplerio-mcp-tools)
- [Contributing](#contributing-and-development)

## What can you do with Coupler.io skills?

Use AI agent skills to:

- Analyze marketing performance across Google Ads, Meta Ads, TikTok Ads, and other channels
- Find wasted PPC spend and opportunities to scale campaigns
- Review sales pipelines, win rates, deal velocity, and rep performance
- Analyze P&L, MRR, ARR, cash runway, and financial performance
- Measure ecommerce conversion, AOV, retention, and repeat purchases
- Generate structured business reports with validated metrics
- Investigate anomalies and explain changes in business KPIs
- Create and configure Coupler.io dataflows through AI

## Quick start

Add the Coupler.io skills marketplace:

```
/plugin marketplace add coupler-io/skills
```

Then install the skill set you need:

```
/plugin install coupler-marketing-ads@coupler-io-skills
/plugin install coupler-finance@coupler-io-skills
/plugin install coupler-sales@coupler-io-skills
/plugin install coupler-ecommerce@coupler-io-skills
```

Install only what you need. Every skill's description stays in context for the whole session, so a plugin costs tokens in proportion to how many skills it carries. See [Installation](#installation) for the full plugin list, team setup, and manual install.

You also need a [Coupler.io](https://coupler.io) account with the MCP server connected, so the skills have live data to work against.

## Skills library

Skills are organized by business function - Finance, Sales, Ecommerce, and Marketing & Ads - with additional shared capabilities and utilities.

### Marketing & PPC

| Skill | What it does |
| --- | --- |
| [**marketing-analytics**](marketing-and-ads/marketing-analytics/SKILL.md) | Marketing performance — campaign analysis, cross-channel comparison, anomaly detection. Covers paid, organic, email, and social. |
| [**ppc-analytics**](marketing-and-ads/ppc-analytics/SKILL.md) | Paid-ads (PPC) performance — per-platform funnel traces, efficiency-first comparison (ranked on CPA/ROAS), budget pacing, ad-fatigue checks, and honest attribution (never blends conversions across platforms; offers an independent-source cross-check and blended CAC). Facebook + Google Ads first-class. |

#### Google Ads deep dives

Eight Google-Ads-only skills in `marketing-and-ads/google-ads/`. Each one owns a single question and hands off to the others rather than duplicating them — `ppc-analytics` stays the cross-platform paid view. When a request needs a field no packaged report type carries, they route to `capability/google-ads-custom-gaql`.

| Skill | What it does |
| --- | --- |
| [**google-ads-performance-review**](marketing-and-ads/google-ads/google-ads-performance-review/SKILL.md) | The baseline read — what changed in the account and why. Period comparison, cost-per-lead moves, impression-share loss. Run this before deciding anything else. |
| [**google-ads-waste-and-scale**](marketing-and-ads/google-ads/google-ads-waste-and-scale/SKILL.md) | The cutting view — search-term waste, negative-keyword candidates, what to pause, and a budget-neutral reallocation proposal. |
| [**google-ads-keyword-and-quality-score-analysis**](marketing-and-ads/google-ads/google-ads-keyword-and-quality-score-analysis/SKILL.md) | The earning view — which keywords deserve more money, which overcharge for the same clicks, match-type and quality-score diagnosis. |
| [**google-ads-budget-pacing**](marketing-and-ads/google-ads/google-ads-budget-pacing/SKILL.md) | Month-end arithmetic — on-track or overspending, daily target, which campaigns are budget-capped, and whether more budget would do anything. |
| [**google-ads-conversion-tracking-audit**](marketing-and-ads/google-ads/google-ads-conversion-tracking-audit/SKILL.md) | Whether the conversion numbers can be trusted at all — double-counting, Analytics disagreement, untracked spend. Run before any cost or return conclusion. |
| [**google-ads-settings-audit**](marketing-and-ads/google-ads/google-ads-settings-audit/SKILL.md) | Account configuration priced in the spend flowing through it — search partners, Display expansion, location intent, auto-apply, ad rotation, conversion windows, bid strategies. |
| [**google-ads-pmax-transparency**](marketing-and-ads/google-ads/google-ads-pmax-transparency/SKILL.md) | Opening the Performance Max black box — Shopping cannibalisation, brand-traffic buying, asset-group performance. |
| [**google-ads-client-report**](marketing-and-ads/google-ads/google-ads-client-report/SKILL.md) | The monthly client write-up — what to say, how to present a missed target. Built only when asked. |

#### TikTok Ads deep dives

Eleven TikTok-only skills in `marketing-and-ads/tiktok-ads/`. Same shape as the Google pack — each owns a single question and routes to its siblings rather than duplicating them, with `ppc-analytics` still the cross-platform paid view.

| Skill | What it does |
| --- | --- |
| [**tiktok-ads-performance-review**](marketing-and-ads/tiktok-ads/tiktok-ads-performance-review/SKILL.md) | The baseline read — what moved, which campaigns moved it, and how much of the change each one caused. Run this before deciding anything else. |
| [**tiktok-ads-waste-and-scale**](marketing-and-ads/tiktok-ads/tiktok-ads-waste-and-scale/SKILL.md) | The cutting view — what to turn off and what to fund with the money, as one decision rather than two. |
| [**tiktok-ads-creative-analysis**](marketing-and-ads/tiktok-ads/tiktok-ads-creative-analysis/SKILL.md) | Which videos earn their spend, where the losing ones lose people, and what the next round should be. |
| [**tiktok-ads-creative-fatigue-and-velocity**](marketing-and-ads/tiktok-ads/tiktok-ads-creative-fatigue-and-velocity/SKILL.md) | Which videos are dying, how long they have left, and how many new ones a month the account needs to keep up. |
| [**tiktok-ads-audience-analysis**](marketing-and-ads/tiktok-ads/tiktok-ads-audience-analysis/SKILL.md) | Which audiences earn their spend — and whether targeting is doing any work the creative was not already doing. |
| [**tiktok-ads-budget-pacing**](marketing-and-ads/tiktok-ads/tiktok-ads-budget-pacing/SKILL.md) | Where the month ends if nothing changes, the daily spend to land on plan, and which ad groups will not take more money. |
| [**tiktok-ads-pixel-and-attribution-audit**](marketing-and-ads/tiktok-ads/tiktok-ads-pixel-and-attribution-audit/SKILL.md) | Whether the conversion numbers can be trusted before you move budget on them. Run before any cost or return conclusion. |
| [**tiktok-ads-structure-and-learning-review**](marketing-and-ads/tiktok-ads/tiktok-ads-structure-and-learning-review/SKILL.md) | Whether the account is split into more ad groups than its budget can feed, priced in what that costs in delivery. |
| [**tiktok-ads-placement-geo-and-device**](marketing-and-ads/tiktok-ads/tiktok-ads-placement-geo-and-device/SKILL.md) | Where and when the money actually goes, and what each of those places is worth. |
| [**tiktok-ads-gmv-max-and-shop-review**](marketing-and-ads/tiktok-ads/tiktok-ads-gmv-max-and-shop-review/SKILL.md) | What GMV Max is actually buying, whether it cannibalises campaigns already making those sales, and which products carry it. |
| [**tiktok-ads-client-report**](marketing-and-ads/tiktok-ads/tiktok-ads-client-report/SKILL.md) | The monthly client write-up — the kind that survives being questioned. Built only when asked. |

#### Meta / Facebook Ads deep dives

Eleven Meta-only skills in `marketing-and-ads/facebook-ads/`. Same shape as the Google pack — each owns a single question and routes to its siblings rather than duplicating them, with `ppc-analytics` still the cross-platform paid view.

| Skill | What it does |
| --- | --- |
| [**facebook-ads-performance-review**](marketing-and-ads/facebook-ads/facebook-ads-performance-review/SKILL.md) | The baseline read — what moved this period and which campaigns moved it. Cost decomposed into CPM, CTR and conversion rate. Run this before deciding anything else. |
| [**facebook-ads-waste-and-scale**](marketing-and-ads/facebook-ads/facebook-ads-waste-and-scale/SKILL.md) | The cutting view — ad sets spending without results, creative past its fatigue threshold, each cut paired with where the money should go instead. |
| [**facebook-ads-creative-analysis**](marketing-and-ads/facebook-ads/facebook-ads-creative-analysis/SKILL.md) | Which ads win and why — thumbstop and hook rate, what the winners have in common, and the brief for the next production round. |
| [**facebook-ads-creative-fatigue**](marketing-and-ads/facebook-ads/facebook-ads-creative-fatigue/SKILL.md) | How long the winners have left — CTR decay against first-week baseline, CPM drift, a refresh queue ranked by spend at risk, and monthly creative volume needed. |
| [**facebook-ads-audience-analysis**](marketing-and-ads/facebook-ads/facebook-ads-audience-analysis/SKILL.md) | Which audiences earn their spend — lookalike vs interest vs broad vs retargeting, saturation as audiences age, and who is being paid for twice. |
| [**facebook-ads-budget-pacing**](marketing-and-ads/facebook-ads/facebook-ads-budget-pacing/SKILL.md) | Month-end arithmetic — on-track or overspending, required daily spend, which ad sets are capped, and whether more budget would do anything. |
| [**facebook-ads-pixel-and-attribution-audit**](marketing-and-ads/facebook-ads/facebook-ads-pixel-and-attribution-audit/SKILL.md) | Whether the conversion numbers can be trusted — pixel and CAPI coverage, deduplication, view-through share, the platform-vs-store gap. Run before any cost or return conclusion. |
| [**facebook-ads-settings-audit**](marketing-and-ads/facebook-ads/facebook-ads-settings-audit/SKILL.md) | Configuration priced in the spend flowing through it — optimisation goals, bid strategy, Advantage+ and expansion toggles, attribution setting. Most of these default in Meta's favour. |
| [**facebook-ads-structure-and-learning-review**](marketing-and-ads/facebook-ads/facebook-ads-structure-and-learning-review/SKILL.md) | How the account is organised and what that costs in learning — ad sets stuck below event volume, fragmentation, audience overlap, consolidation with the spend affected. |
| [**facebook-ads-placement-geo-and-device**](marketing-and-ads/facebook-ads/facebook-ads-placement-geo-and-device/SKILL.md) | Where the budget actually goes — Feed vs Reels vs Stories vs Audience Network, region, device and delivery hour, each with what it is worth. |
| [**facebook-ads-client-report**](marketing-and-ads/facebook-ads/facebook-ads-client-report/SKILL.md) | The monthly client write-up — KPIs against goal, creative winners, the attribution caveat stated once and plainly. Built only when asked. |

### Sales

| Skill | What it does |
| --- | --- |
| [**sales-analytics**](sales/sales-analytics/SKILL.md) | Sales pipeline — win rates, velocity, cycle length, rep performance, stage conversion. Works with Salesforce, HubSpot, Pipedrive, Close, Zoho, and more. |

### Finance

| Skill | What it does |
| --- | --- |
| [**finance-analytics**](finance/finance-analytics/SKILL.md) | Financial performance — P&L review, MRR/ARR bridge, cash runway, cost-center investigation. Works with QuickBooks, Xero, NetSuite, Stripe, Sage, and more. |

### Ecommerce

| Skill | What it does |
| --- | --- |
| [**ecom-analytics**](ecommerce/ecom-analytics/SKILL.md) | E-commerce performance — funnel conversion, AOV, cohort retention, repeat purchase, anomaly detection. Works with Shopify, WooCommerce, GA4, Klaviyo, Stripe, and more. |

### Capabilities

Shared building blocks. Compose these with any domain skill above.

| Skill | What it does |
| --- | --- |
| [**get-started**](capability/get-started/SKILL.md) | Onboard a brand-new or empty workspace from zero to the user's own data in the chat — anchor on stated intent, route template-or-scratch, script the guided credential round-trip, build + run the first dataflow, then offer a refresh schedule. |
| [**create-dataflow**](capability/create-dataflow/SKILL.md) | Configure a Coupler.io dataflow end to end — pick an integration, attach a credential, wire source → destination, and trigger a run. |
| [**google-ads-custom-gaql**](capability/google-ads-custom-gaql/SKILL.md) | Build a Custom GAQL source when no packaged Google Ads report type carries the field — and name the packaged type when one does. Covers resource choice, date macros, and the raw column names and micros that come back. |
| [**generate-data-set-context**](capability/generate-data-set-context/SKILL.md) | Produce an AI-readable description for a dataset so future sessions inherit its schema context. |
| [**refine-prompt**](capability/refine-prompt/SKILL.md) | Sharpen a vague or underspecified analytics request into a detailed, actionable prompt — filling in time period, metrics, data sources, and output format — before analysis. |
| [**report-generation**](capability/report-generation/SKILL.md) | Industry-agnostic report formatter and validator. Turns analysis output into a structured TL;DR → Metrics → Context → Recommendations → Next Questions report, then runs a Phase 2 validation pass (arithmetic, units, claim-vs-data, logical gates). Compose with a domain skill for domain-flavored reports. |

### Utilities

| Skill | What it does |
| --- | --- |
| [**humanizer**](utilities/humanizer/skills/humanizer/SKILL.md) | Rewrites AI-generated text to remove detectable patterns and add human voice. Also available as the `/humanize` slash command. |
| [**coupler-live-artifact**](utilities/coupler-live-artifact/SKILL.md) | Builds a live Cowork artifact — a persistent, re-openable HTML widget backed by a Coupler.io dataflow that auto-refreshes (live dashboards, daily-check pages, data explorers). |

---

## Example questions

### Marketing & PPC

- Why did Google Ads ROAS decline last week?
- Which campaigns are wasting budget?
- Which Meta Ads creatives are showing signs of fatigue?
- Are we on track to spend our advertising budget this month?

### Sales

- What is our current pipeline coverage?
- Which stage has the biggest conversion drop?
- Which reps have the shortest sales cycles?

### Finance

- What changed in our P&L this month?
- How many months of cash runway do we have?
- Explain the movement in MRR versus last month.

### Ecommerce

- Which products contributed most to revenue growth?
- How has repeat purchase rate changed?
- Which customer cohorts have the strongest retention?

## How Coupler.io skills work

A skill is a reusable set of instructions that tells an AI agent how to perform a specific analytics task.

The skill uses Coupler.io MCP tools to discover datasets, inspect schemas, query live business data, and return a structured analysis.

Skills define **how to analyze** your data.
Coupler.io MCP provides **access to the data and tools** needed to perform the analysis.

---

## Installation

**From the marketplace** — add this repo as a plugin marketplace, then install the per-cluster plugin(s) you want:

```
/plugin marketplace add coupler-io/skills
/plugin install coupler-finance@coupler-io-skills
```

Each business function is its own plugin, so you install only what you need. Available plugins:

| Plugin | Skills it installs |
| --- | --- |
| `coupler-finance` | finance-analytics |
| `coupler-sales` | sales-analytics |
| `coupler-ecommerce` | ecom-analytics |
| `coupler-marketing-ads` | marketing-analytics, ppc-analytics, + the 8 Google Ads, 11 Meta / Facebook Ads and 11 TikTok Ads deep dives |
| `coupler-capability` | get-started, create-dataflow, google-ads-custom-gaql, generate-data-set-context, refine-prompt, report-generation |
| `coupler-utilities` | coupler-live-artifact |
| `humanizer` | humanizer (+ `/humanize` command) |

Plugin skills are namespaced by their plugin, so they can be invoked explicitly as `/coupler-finance:finance-analytics`. Most of them are model-invoked too — Claude reaches for them when the request matches their description. If the install summary says `Run /reload-plugins to activate.`, run that.

**Install only the plugin you need.** Every skill's description stays in context for the whole session, so a plugin's cost scales with how many skills it carries. `coupler-marketing-ads` bundles 32 and adds roughly 5.5k tokens to every session; the single-skill plugins add a few hundred. Check any plugin before installing it:

```
claude plugin details coupler-marketing-ads@coupler-io-skills
```

**For a whole team** — register the marketplace in the repository's `.claude/settings.json` so collaborators get it once they trust the folder:

```json
{
  "extraKnownMarketplaces": {
    "coupler-io-skills": {
      "source": {
        "source": "github",
        "repo": "coupler-io/skills"
      }
    }
  }
}
```

This adds the marketplace, not the plugins. Each person still runs `/plugin install <plugin>@coupler-io-skills` to pick what they want. To pre-enable plugins as well, see [`enabledPlugins`](https://code.claude.com/docs/en/settings-reference#plugin-settings).

**Manual** — copy any skill folder (each contains a `SKILL.md`) into your project's `.claude/skills/` directory. Skills installed this way are not namespaced, and Claude activates them when the request matches their description.

---

## Coupler.io MCP tools

These are the tools the Coupler.io MCP server exposes. Skills use them automatically — you only need to know them if you are writing a new skill or calling tools directly.

### Skills

| Tool | Description |
| --- | --- |
| `list-skills` | Names + one-line descriptions of every available skill. Always the first call. |
| `get-skill` | Full procedure for a named skill. |

### Discovery

| Tool | Description |
| --- | --- |
| `list-templates` | Pre-built recipes filtered by source, metric, or category. Fastest path to skip manual setup. |
| `list-integrations` | Every integration the platform supports (400+). |
| `list-credentials` | What the user is already authorized for. |
| `list-datasets` | Every dataset across every dataflow. Use for full-picture browsing. |
| `search-datasets` | Narrows datasets by name, source, or free-text. Prefer over `list-datasets` when you have a keyword. |

### Inspection

| Tool | Description |
| --- | --- |
| `get-integration` | Parameters and auth shape for one integration. Required before configuring anything. |
| `get-integration-field-options` | Resolves dynamic dropdown values (e.g. Salesforce objects, Google Ads accounts). Call when `get-integration` flags `resolve_options_with_tool: true`. |
| `get-dataflow` | Current state of one dataflow — sources, destinations, schedule, last run. |
| `get-schema` | Column types and AI context for one dataset. Required before querying. |
| `get-data` | SQL against the dataset's `data` table. Start with `SELECT * FROM data LIMIT 5` to confirm shape. |

### Configuration

| Tool | Description |
| --- | --- |
| `create-dataflow` | Create a new empty dataflow. |
| `create-dataflow-from-template` | Create a fully configured dataflow from a template. Use when `list-templates` returns a match — skips manual assembly. |
| `create-dataflow-source` | Attach a source (Stripe, Postgres, …) to a dataflow. |
| `create-dataflow-destination` | Attach a destination (Sheets, BigQuery, Looker Studio, …) to a dataflow. |
| `update-dataflow-source` | Change source parameters; merges into existing config. |
| `update-dataflow-destination` | Change destination parameters. |

### Run & persist

| Tool | Description |
| --- | --- |
| `run-dataflow` | Kick off a refresh from the source. |
| `update-dataset` | Save a markdown description on a dataset so future sessions inherit it. |

> **Deprecated:** `list-dataflows` — replaced by `list-datasets`.

---

## Contributing and development

The machine-readable catalog is `skills-index.json`. **Do not edit it by hand** — it is generated from `SKILL.md` frontmatter. Change the skill files, then run `python .github/scripts/generate_skill_index.py`, or let the GitHub Action regenerate it on merge to `main`.
