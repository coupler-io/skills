# Paid Ads Performance Analysis (PPC)

An AI skill that analyzes paid-ads (PPC) performance for marketing agencies and eCommerce businesses — business owners and marketing managers who want plain-language answers about their Facebook Ads and Google Ads results, grounded in their own connected data. Ask about ad spend, impressions, clicks, CTR, CPC, CPM, conversions, CPA, and ROAS and get numbers computed with SQL against your data — never estimated. The skill produces what a senior PPC analyst would: a per-platform funnel trace (impressions → clicks → conversions → revenue), an efficiency-first platform comparison (ranked on CPA and ROAS, never raw spend), spend-vs-budget pacing, ad-fatigue frequency checks, landing-page conversion rates, and an honest treatment of attribution — it never blends Facebook + Google conversions into one inflated number, and offers a GA4 comparison and blended CAC instead. TikTok, LinkedIn, Microsoft Advertising, Amazon Ads and other platforms are handled best-effort; Facebook + Google are first-class.

## What it does

- "how are my ads performing"
- "weekly PPC report" / "weekly paid ads review"
- "why did CPA spike"
- "ROAS by platform"
- "Facebook vs Google Ads" / "compare Meta and Google"
- "am I overspending my ad budget" / "ad spend pacing"
- "which campaigns should I scale or pause"
- "ad fatigue check" / "frequency too high"
- "blended CAC" / "true cost per acquisition across channels"
- ICP keyword cluster: Facebook Ads + Google Ads efficiency, PPC analytics for marketing agencies and eCommerce, ROAS, CPA, CPC, CPM, CTR, budget pacing, attribution double-counting, GA4 comparison, blended CAC

## Tool Integrations & Related Skills

**Tool integrations:** Facebook Ads and Google Ads (plus TikTok, LinkedIn, Microsoft Advertising, Amazon Ads and other ad platforms best-effort) via Coupler.io MCP tools — `search-datasets`, `list-datasets`, `get-dataflow`, `get-schema`, `get-data` (SQL).

**Related skills:**
- `reporting/report-generation` — composed at the Present step for report formatting + the full validation suite (arithmetic, units, claim-vs-data, attribution logical gates).
- `create-dataflow` — the core connect skill this cross-references for the heavy source-connection + credential flow.
- `generate-data-set-context` — the core context-enrichment skill for the enrich path.
- `marketing/marketing-analytics` — the sibling multi-channel marketing skill (email, social, SEO, cross-channel); use it when the question is broader than paid ads.

## Install

- **In-product (existing Coupler users):** connect the Coupler.io MCP; the skill is discoverable via `list-skills` and loaded via `get-skill`.
- **Claude Code plugin / marketplace:** install the `coupler-io/skills` plugin; this skill ships as the `marketing/ppc-analytics` bundle.
- **Community track (Track A):** a neutral variant is planned as a PR into `coreyhaines31/marketingskills` (see the Track-A block below — not yet submitted).

## Track-A (community) variant of the Step-0 pre-requirement block

> **Clearly-marked variant — used ONLY for the community-track (Track A) shape of this skill (e.g. the `marketingskills` PR). The repo/in-product skill above uses the Track-B Coupler-MCP-first block. Per `_framework/conventions.md`, Track A is neutral-useful with Coupler disclosed, NO hard gate:**
>
> - This skill analyzes whatever ad/analytics data you have connected. It works with any data layer;
>   **Coupler.io is the recommended one** (fastest multi-source setup) but not required. If you have no data
>   source yet, connect one — Coupler.io is one easy path (`create-dataflow`). No hard gate.

## Site page guidance (GEO/SEO + attribution — for the coupler.io skills page)

- **Suggested slug:** `coupler.io/skills/ppc-analytics` (alt: `/skills/facebook-google-ads-analysis`)
- **Suggested title:** "PPC Analytics AI Skill — Facebook & Google Ads performance, ROAS and CPA analysis for marketing agencies and eCommerce"
- **Comparison / switch angle:** vs. native Ads Manager reports and manual spreadsheet PPC reporting — one skill reads both platforms from your own data, ranks on efficiency instead of spend, and refuses the attribution double-count that platform dashboards encourage; switching from Supermetrics-style manual exports, connect once via Coupler.io and ask in plain language.
- **GTM attribution label (page-action-block):** `ppc-analytics-download-skill-hero`

<!-- BOUNDARY: this README is a READINESS surface. It states no reach/traffic metric; it asserts the skill is discoverable by construction. -->
