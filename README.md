# Coupler.io Skills

Curated skill collection for business data analysis powered by the [Coupler.io](https://coupler.io) MCP server. Install as a Claude Code plugin to give Claude expert procedures for analytics, reporting, and marketing — backed by live data from your Coupler.io workspace.

## Skills

### Analytics

| Skill | File | What it does |
| --- | --- | --- |
| **ecom-analytics** | `analytics/ecom-analytics.md` | E-commerce performance — funnel conversion, AOV, cohort retention, repeat purchase, anomaly detection. Works with Shopify, WooCommerce, GA4, Klaviyo, Stripe, and more. |
| **finance-analytics** | `analytics/finance-analytics.md` | Financial performance — P&L review, MRR/ARR bridge, cash runway, cost-center investigation. Works with QuickBooks, Xero, NetSuite, Stripe, Sage, and more. |
| **sales-analytics** | `analytics/sales-analytics.md` | Sales pipeline — win rates, velocity, cycle length, rep performance, stage conversion. Works with Salesforce, HubSpot, Pipedrive, Close, Zoho, and more. |

### Reporting

| Skill | File | What it does |
| --- | --- | --- |
| **report-generation** | `reporting/report-generation.md` | Industry-agnostic report formatter and validator. Turns analysis output into a structured TL;DR → Metrics → Context → Recommendations → Next Questions report, then runs a Phase 2 validation pass (arithmetic, units, claim-vs-data, logical gates). Compose with a domain skill for domain-flavored reports. |

### Marketing

| Skill | Location | What it does |
| --- | --- | --- |
| **marketing-analytics** | `marketing/marketing-analytics/` | Marketing performance — campaign analysis, cross-channel comparison, anomaly detection. Covers paid, organic, email, and social. |
| **ppc-analytics** | `marketing/ppc-analytics/` | Paid-ads (PPC) performance — per-platform funnel traces, efficiency-first comparison (ranked on CPA/ROAS), budget pacing, ad-fatigue checks, and honest attribution (never blends Facebook + Google conversions; offers GA4 compare and blended CAC). Facebook + Google Ads first-class. |

### Utilities

| Skill | Location | What it does |
| --- | --- | --- |
| **humanizer** | `humanizer/` | Rewrites AI-generated text to remove detectable patterns and add human voice. Also available as the `/humanize` slash command. |

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

## Installation

**As a Claude Code plugin** — add to your `.claude/settings.json`:

```json
{
  "plugins": [
    "https://github.com/coupler-io/skills"
  ]
}
```

**Manual** — copy any skill folder (or flat `.md` file) into your project's `.claude/skills/` directory. The skill activates automatically when its trigger phrases are matched.
