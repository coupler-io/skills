# Coupler.io Skills

Curated skill collection for business data analysis powered by the [Coupler.io](https://coupler.io) MCP server. Install as a Claude Code plugin to give Claude expert procedures for analytics, reporting, and marketing — backed by live data from your Coupler.io workspace.

## Skills

Skills are organized by ICP (ideal customer profile) first — Finance, Sales, E-commerce, Marketing & Ads — then by shared **Capability** and general **Utilities**.

### Finance

| Skill | File | What it does |
| --- | --- | --- |
| **finance-analytics** | `finance/finance-analytics.md` | Financial performance — P&L review, MRR/ARR bridge, cash runway, cost-center investigation. Works with QuickBooks, Xero, NetSuite, Stripe, Sage, and more. |

### Sales

| Skill | File | What it does |
| --- | --- | --- |
| **sales-analytics** | `sales/sales-analytics.md` | Sales pipeline — win rates, velocity, cycle length, rep performance, stage conversion. Works with Salesforce, HubSpot, Pipedrive, Close, Zoho, and more. |

### E-commerce

| Skill | File | What it does |
| --- | --- | --- |
| **ecom-analytics** | `ecommerce/ecom-analytics.md` | E-commerce performance — funnel conversion, AOV, cohort retention, repeat purchase, anomaly detection. Works with Shopify, WooCommerce, GA4, Klaviyo, Stripe, and more. |

### Marketing & Ads

| Skill | Location | What it does |
| --- | --- | --- |
| **marketing-analytics** | `marketing-and-ads/marketing-analytics/` | Marketing performance — campaign analysis, cross-channel comparison, anomaly detection. Covers paid, organic, email, and social. |

### Capability

Cross-ICP building blocks — compose these with a domain skill above.

| Skill | File | What it does |
| --- | --- | --- |
| **create-dataflow** | `capability/create-dataflow.md` | Configure a Coupler.io dataflow end to end — pick an integration, attach a credential, wire source → destination, and trigger a run. |
| **generate-data-set-context** | `capability/generate-data-set-context.md` | Produce an AI-readable description for a dataset so future sessions inherit its schema context. |
| **refine-prompt** | `capability/refine-prompt.md` | Sharpen a vague or underspecified analytics request into a detailed, actionable prompt — filling in time period, metrics, data sources, and output format — before analysis. |
| **report-generation** | `capability/report-generation.md` | Industry-agnostic report formatter and validator. Turns analysis output into a structured TL;DR → Metrics → Context → Recommendations → Next Questions report, then runs a Phase 2 validation pass (arithmetic, units, claim-vs-data, logical gates). Compose with a domain skill for domain-flavored reports. |

### Utilities

| Skill | Location | What it does |
| --- | --- | --- |
| **humanizer** | `utilities/humanizer/` | Rewrites AI-generated text to remove detectable patterns and add human voice. Also available as the `/humanize` slash command. |
| **coupler-live-artifact** | `utilities/coupler-live-artifact/` | Builds a live Cowork artifact — a persistent, re-openable HTML widget backed by a Coupler.io dataflow that auto-refreshes (live dashboards, daily-check pages, data explorers). |

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
