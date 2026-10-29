---
name: platform-rules
description: "Use this skill to keep the platform rules that Coupler.io skills state as fact current: budget flexibility, deliverability thresholds, attribution windows, published benchmarks, plan limits, sale dates. Triggers include: 'refresh the platform rules', 'check the Google Ads rules', 'is the Klaviyo benchmark still current', 'a platform changed its budget rules', 'add this rule to the registry'. Works from registry.md, a catalog of every rule, its source, when it was checked and which skills use it, so a refresh checks the sources instead of rereading every skill."
metadata:
  version: 1.0.0
  category: utilities
  sources: []
---

# Platform Rules

Skills in this repo state platform rules as fact: Google may spend 2× a daily budget, Klaviyo's spam
band ends at 0.05%, TikTok allows 30% budget steps. Platforms change these on their own schedule, and
the same rule is copied into several skills. [registry.md](registry.md) is the catalog of those rules:
the value, the platform page it comes from, the date it was last checked, and the skills that use it.

The skills keep the value inline. An agent loading a skill through the MCP sees only that file, so the
registry is for maintainers, never a runtime dependency.

## What counts as a platform rule

A statement belongs in the registry when all three hold:

1. **The skill states it as fact and the model acts on it.** A threshold that sets a verdict, a window
   that decides which days are complete, a limit that sizes a recommendation.
2. **Something outside the skill sets it**: an ad, email, store or search platform, or Coupler.io's
   own product.
3. **It can change without anyone editing the skill.**

The kinds that qualify:

| Kind | Examples |
|---|---|
| Limits and thresholds | Daily budget flexibility, budget step sizes, spam and bounce bands, inspection quotas |
| Windows and defaults | Attribution windows, data-freshness lags, the timezone a platform reports in |
| Published benchmarks | Revenue per recipient by flow, tickets per order. Always with the publication date |
| Platform guidance that changes the advice | When seasonality adjustments help, whether a target change restarts learning |
| Coupler.io product rules stated as a number or default | Refresh intervals by plan, schedule defaults |
| Calendar facts | Black Friday and Cyber Monday dates, which move every year |

What does **not** belong here:

- **Connector facts**: column names, report types, `mcp_excluded_params`, what a column holds. They
  change with Coupler releases and are checked against config and importer code (`skill-review`
  items 2, 3 and 7).
- **Method choices**: volume floors, break rules, threshold multiples. These are the skill's own
  design, not something a platform sets.
- **Definitions**: CTR is clicks over impressions whatever the platform says.

## How a rule is written in a skill

The value, its source and the date it was checked, inline where the model uses it:

> A campaign may spend up to 2× its average daily budget on one day and no more than 30.4× it in a
> month (Google Ads help, support.google.com/google-ads/answer/2375423, checked 2026-10-28).

Once per skill, where the rules are used, add the check instruction:

> If you can browse the web, check the platform's page; if it says something different, use the page
> and say the skill's figure is out of date. If you can't, use these figures and give the date.

"Check the docs" on its own is not a rule. In clients without web access it means "recall"
(`skill-review` item 8).

## Refresh

Run on request, for every rule or one platform's rows.

1. **Fetch each source** in the registry and compare it with the stored value. Platform pages only.
   A blog or agency post can tell you a change happened, never what the rule now is.
2. **Classify each row:**
   - **Unchanged.** Update `Checked`.
   - **Changed.** Record the new value with a short quote from the page.
   - **Unverifiable.** The page didn't load or no longer states the rule. Leave the value and say so;
     never fill it from memory or a third party.
3. **For each changed rule:**
   1. Update every skill in `Used in`, keeping each skill's wording and the inline "checked" date.
   2. Search the repo for the old value (for example `30.4`, `0.05%`, `$6.77`) to catch copies the
      registry missed. Add them to `Used in`.
   3. Bump each edited skill's patch version.
4. **Open one PR** with a table of every changed rule: old value, new value, quote, source, skills
   touched. Unchanged rows go in as a single "rechecked" line. Unverifiable rows are listed so a
   person can check them by hand.

Work the `Unchecked` section the same way, a few rows per run. A row moves to `Verified` only when
its platform page has been read.

## Adding a rule

When a review or a new skill introduces a rule:

1. Check it is not already in the registry under another name. If it is, the new skill uses the
   registry's value; a different value is a contradiction between packs (`skill-review` item 5).
2. Fetch the platform page and add a row: value as stated, source URL, today's date, status, and the
   skill and search text in `Used in`.
3. If the page can't be read, add the row as `Unverifiable` or `Secondhand` rather than leaving the
   rule out. A known gap is checkable later; a missing row is invisible.

## Statuses

| Status | Meaning |
|---|---|
| Verified | The platform's own page was read on the `Checked` date and states this value |
| Secondhand | Seen only through another party citing the platform (another vendor's help page, a search summary). Check the primary source next refresh |
| Unverifiable | The platform's page couldn't be read. The value is a working rule; skills must say so |
| Unchecked | Found in a skill; no one has checked it against a source yet |

## Guidelines

- Verify or say you did not. A stale `Checked` date is better than a fresh one nobody earned.
- Quote the page. The quote is what lets the next maintainer see whether the wording moved.
- One value per rule across the repo. Two skills disagreeing is a defect in one of them.
- This skill updates itself the same way `skill-review` does: through a PR against this file, never
  silently in the middle of a refresh.
