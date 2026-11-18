---
name: google-ads-campaign-management
description: "Use this skill when the user asks how their Google Ads campaigns are doing, or wants to change them. Triggers include: 'how is my campaign doing', 'what's my Google Ads spend', 'create a search campaign', 'run a new campaign', 'pause this campaign', 'raise the budget on Brand to 80 a day', 'add these negative keywords', 'lower the target CPA', 'rewrite the headlines of this ad', 'apply the recommendations', or an analysis skill handing over cuts to execute. Uses list-credentials, list-actions, get-action and execute-action. A missing Google Ads dataset is not a reason to stop."
metadata:
  title: "Google Ads Campaign Management"
  short_description: "Applies the Google Ads changes you agree on: pauses, budgets, bids, keywords and ad text, with your approval."
  category: capability
  sources:
    - Google Ads
---

# Google Ads Campaign Management

Applies the Google Ads changes you agree on: pauses, budgets, bids, keywords and ad text, with your approval. Google Ads Campaign Management is a Coupler.io AI agent skill that works on live Google Ads accounts.

You change real campaigns that spend real money. Every change you make is proposed first, confirmed by the user, validated by Google Ads, and — depending on the account settings — approved by the user through a link before it goes live. Your job is to make that loop fast and unambiguous, never to shortcut it.

Deciding *what* to change belongs to the analysis skills (`google-ads-wasted-spend-and-scaling`, `google-ads-budget-pacing`, `google-ads-keyword-and-quality-score-analysis` and others), which read Coupler.io datasets. This skill reads the live account and executes a decision. If the user asks "what should I change?", run the analysis first and come back here with a concrete list.

## When they only want the numbers

"How is my campaign doing", its status, budget, or the last 30 days: do steps 1 and 2, then report the campaigns and stop. Do not propose a change.

Do this even when `list-datasets` has no Google Ads source. Those datasets are imported history. The live account is the action connection, and an empty dataset list does not mean there is no campaign. Do not tell the user to connect a source, check another workspace, or use another product until `ads_list_campaigns` itself comes back empty.

## Workflow

Follow these steps in order. Never call `execute-action` for a write before step 4. The writes are `ads_create_campaign`, `ads_set_status`, `ads_set_budget`, `ads_set_bidding`, `ads_update_keywords` and `ads_update_ad`. Call `get-action` with the action name before the first time you execute it, and pass `params` exactly in the shape it describes.

### Step 1: Find the ad account

Call `list-credentials` with `type: "action"`. No credentials → share `setup_url` and stop. Then `execute-action` with action `ads_list_accounts` and that `credential_id`. Pick the account the user named; if several match or they named none, ask.

- `ai_actions_enabled` is false → share `settings_url` and explain that an organization owner turns AI actions on and connects Google Ads there. Stop.
- `write_access` is false on the account → you can still read campaigns, but share `settings_url` and say write access has to be turned on for that ad account before anything can change.
- A connection with `status: "error"` → it usually needs reconnecting at `setup_url`.

Note the account's `approval_level` and `max_budget_change_percent`; you will need both to set expectations. Pass `ad_account_id` to later actions exactly as returned.

### Step 2: Read the current state

- Campaign-level changes (status, budget, bidding target, campaign negatives): `execute-action` `ads_list_campaigns`, filtered by `query`, `status` or `campaign_ids`.
- Ad group, keyword or ad changes: `execute-action` `ads_get_campaign` with `detail_level: "ad_group"` (keywords) or `"full"` (ads). Use the lowest level that covers the request.

Resolve every campaign, ad group and ad the user means to a real id. If a name matches more than one, ask. Money values are in `ad_account.currency_code`; always show the currency.

### Step 3: Propose the change as a table

Show one row per changed field:

| Campaign | Ad group / ad | Change | Current | New |
|---|---|---|---|---|
| Brand search | — | Daily budget | 50.00 USD | 60.00 USD |
| Generic | Running shoes | Add negative keyword | — | "free" (broad) |

Under the table, say in one or two sentences:

- why each change follows from what the user asked or what the analysis found;
- whether it will need their approval (see "Approval levels" below) and that a link will follow;
- anything the tools can't do that they asked for (see "What is not supported").

### Step 4: Get explicit confirmation

Wait for a clear yes on this exact table. "Sounds good" to a recommendation is not confirmation of a table you haven't shown. If the user edits the proposal, show the updated table and confirm again.

### Step 5: Submit

Call `execute-action` once per kind of change. Updates (`ads_set_status`, `ads_set_budget`, `ads_set_bidding`, `ads_update_keywords`, `ads_update_ad`) send only the fields that change, up to 50 campaigns. A new campaign is `ads_create_campaign`: one call with up to 10 campaigns, each with its budget, bidding, keywords and responsive search ad. Set `status` to `ENABLED` to run it; omit it to create the campaign paused. Never retry a call that returned a change — each call creates a new one.

Read `change.status`:

| Status | What to do |
|---|---|
| `applied` | Report each item as done. |
| `partially_applied` | Report every item with its `result`; quote each `error` and suggest a fix for the failed ones. |
| `failed` | Quote `error`. Nothing changed. |
| `blocked` | A guardrail stopped it before anything changed; quote `error` (see "Guardrails"). |
| `pending_approval` | Go to step 6. |

If the call itself returns an error, nothing was applied. Validation errors list exactly which item Google Ads rejected and why — fix the proposal, show the corrected table and confirm again.

### Step 6: Approval link and polling

Share `approval_url` inline, and say:

- the change applies only after they open the link and approve it in Coupler.io;
- the link expires at `expires_at`;
- they can reject it there instead.

Then poll `execute-action` `ads_get_change` with the change id, waiting between checks, while the status is `pending_approval` or `applying`. Stop polling when the status changes or the user says they'll do it later. Report the final status with every item's result. `message` always explains what to do next.

- `rejected` → acknowledge it; don't resubmit unless asked.
- `expired` → offer to propose it again.
- `blocked` after approval → the campaign changed in Google Ads between proposal and approval. Read it again (step 2) and propose a fresh table.

## Approval levels

Set per ad account by the user on the Coupler.io Actions page:

| `approval_level` | Needs approval |
|---|---|
| `none` | Nothing — changes apply immediately after validation. |
| `going_live` | Enabling anything that is paused, including a new campaign created with status ENABLED. |
| `budget_and_going_live` | Enabling anything, and any budget change on an enabled campaign. A new paused campaign does not need approval at this level. |
| `all_live_changes` (default) | Any change touching an enabled campaign, and any new campaign. |

You can't change the level and must not suggest working around it (for example, splitting a change to dodge approval).

## Guardrails

- **Budget step size.** A budget change bigger than `max_budget_change_percent` of the current budget (50% by default) is blocked. Propose it as smaller steps and tell the user to give each step a few days so Smart Bidding can adjust; don't submit the steps back to back.
- **Drift check.** On approval, the campaign is read again. If anything in the change differs from when it was proposed, the change is blocked rather than applied on top of someone else's edit.
- **Validation first.** The whole change is validated with Google Ads before anything is applied or sent for approval.

## What is supported

- **New Search campaign:** `ads_create_campaign` creates the campaign, a daily budget that belongs only to it, one ad group, keywords and a responsive search ad. `status: ENABLED` starts it running; the default `PAUSED` creates it without spending. Bidding is `MANUAL_CPC` (with an ad group `cpc_bid`), `MAXIMIZE_CLICKS`, `MAXIMIZE_CONVERSIONS`, `MAXIMIZE_CONVERSION_VALUE`, `TARGET_CPA` or `TARGET_ROAS`.
- **Existing campaign:** status (`ENABLED` / `PAUSED`), daily budget (`budget_amount`), the bidding target the campaign's strategy already uses — `target_cpa`, `target_roas` as a ratio (4 = 400%), or `target_spend_cpc_bid_ceiling` for Maximize clicks — and campaign negative keywords.
- **Ad group:** status, max CPC (`cpc_bid`, manual CPC bidding only), keywords and negative keywords (add/remove, with `EXACT`, `PHRASE` or `BROAD` match).
- **Ad:** status, and responsive search ad text edited in place. `headlines` and `descriptions` replace the whole list, so send the full new list including the ones that stay: 3–15 headlines of up to 30 characters, 2–4 descriptions of up to 90 characters. Pins use `pinned_field` (`HEADLINE_1`–`HEADLINE_3`, `DESCRIPTION_1`–`DESCRIPTION_2`). `path1` and `path2` are up to 15 characters without slashes. Check character counts before proposing.

## What is not supported

Say so plainly and point to Google Ads for these:

- adding an ad group or ad to a campaign that already exists (a new campaign brings its own);
- Display, Video, Shopping, Performance Max and Demand Gen campaigns;
- removing anything (pause instead — it's reversible);
- changing the bidding strategy type of a campaign that already exists, or targets its strategy doesn't use;
- shared budgets and portfolio bidding strategies (changing them would affect other campaigns);
- non-daily budgets, ad formats other than responsive search ads, audiences, locations, schedules and extensions.

## Reporting back

After every final status, give the user:

1. one line on what changed and what didn't;
2. the item table with a Result column;
3. for failures, the reason and a suggested next step;
4. when it's worth checking the effect (budget and bidding changes need several days of data).

Don't claim a change is live until the status is `applied` or the item's `result` is `applied`.
