---
name: marketing-analytics
description: >
  Analyze marketing performance data using Coupler.io MCP tools (list-dataflows, get-schema, get-data). Use when the user asks to pull or analyze data from Coupler.io dataflows/data sets, generate marketing performance reports, understand campaign ROI, or investigate changes in business metrics. Make sure to use this skill whenever the user mentions Coupler.io data, marketing dashboards, channel comparisons, campaign analysis, or asks questions like "why did conversions drop",
  "which channel has best ROI", "where should I spend more", "what's working",
  "show me my marketing numbers", "pull my latest data", even if they don't
  explicitly say "marketing analytics".
---

# Marketing Analytics

Analyze marketing performance across channels using data from Coupler.io dataflows. This skill guides you through retrieving data, computing key metrics, detecting anomalies, and presenting actionable insights — all in language a marketing manager can act on.

## Coupler.io Data Access Workflow

Every analysis starts by connecting to the user's data through Coupler.io MCP tools. Follow this sequence:

### Step 1: Discover available data

Call `list-dataflows` to see what marketing data the user has connected. Each dataflow represents a data pipeline (e.g., "Google Ads → Claude", "Mailchimp Campaigns", "GA4 Traffic").

Look at the dataflow names and source types to understand what channels are available. If the user asks about a specific channel, find the matching dataflow. If they want a cross-channel view, identify all relevant dataflows or the one that contains all of them.

### Step 2: Get dataflow details

For each relevant dataflow, call `get-dataflow` with the dataflow's ID. This returns:

- `last_successful_execution_id` — you need this for querying data
- `schedule` — how often the data refreshes (helps set expectations about data freshness)
- `sources` — details about what's connected and whether it's healthy

### Step 3: Understand the data structure

Call `get-schema` with the `executionId` (from `last_successful_execution_id`). This returns column definitions. Pay attention to:

- `columnName` — the actual column name used in SQL queries (typically `col_0`, `col_1`, etc.)
- `label` — the human-readable name (e.g., "Campaign Name", "Impressions", "Spend")

Build a mental mapping between labels and columnNames. You'll use columnNames in SQL but labels when communicating with the user.

### Step 4: Query the data

Call `get-data` with the `executionId` and an SQL query. The data lives in a SQLite table called `data`.

**Always start with a sample query:**

```sql
SELECT * FROM data LIMIT 5
```

This helps you verify column contents match expectations before running complex queries.

**Key SQL rules:**

- Use `columnName` values (col_0, col_1, ...) in SQL, not human-readable labels
- The table is always called `data`
- SQLite syntax applies (e.g., `||` for string concatenation, no `ILIKE`)
- Date functions: `date()`, `strftime()`, `julianday()` for date arithmetic
- Use `CAST(col_X AS REAL)` when aggregating numeric columns that may be stored as text

### Handling multiple dataflows

When the user needs data from multiple channels, query each dataflow separately and synthesize the results. Explain what you're pulling from each source so the user understands the data lineage.

## Performance Reporting

When the user asks for a marketing performance report, follow this structure:

### Identify the reporting period

Ask the user what time period they want (or infer from context — "last week", "this month", "Q1"). Use the date columns in the data to filter appropriately.

### Pull and compute KPIs

For each channel present in the data, compute the relevant metrics. See `references/channel-metrics.md` for the full catalog of metrics by channel, including definitions, formulas, and benchmark ranges.

### Structure the report output

**Key Metrics** — the 3-5 most important numbers with period-over-period change:

- Show the metric value, the change (absolute and percentage), and a directional indicator
- Example: "Conversions: 1,247 (+18% WoW) — strongest week this month"

**Trends** — what's moving and in what direction:

- Identify metrics with consistent upward or downward movement over 4+ periods
- Flag any inflection points (where direction changed)

**Channel Breakdown** — performance by marketing channel:

- Compare channels on efficiency (CPA, ROAS) not just volume
- Highlight the best and worst performing channels

**Recommendations** — 2-3 specific actions based on the data:

- Each recommendation should cite the supporting data
- Prioritize by expected impact

After recommendations, ask one follow-up question to engage user about the most important thing such as further anomaly discovery, inflection points, or more detailed analysis.

See `references/report-templates.md` for weekly, monthly, and quarterly report structures.

## Campaign Analysis

When the user wants to deep-dive into a specific campaign or channel:

### Spend efficiency

Calculate and present:

- **CPA** (Cost per Acquisition): total spend / conversions
- **ROAS** (Return on Ad Spend): revenue / ad spend
- **CPM** (Cost per Mille): (spend / impressions) * 1000
- Compare these against the user's historical averages or industry benchmarks from `references/channel-metrics.md`

IMPORTANT: never calculate yourself, send SQL queries to Coupler.io instead using the `get-data` tool.

### Funnel analysis

If the data supports it, trace the full funnel:

1. **Impressions** — how many people saw the message
2. **Clicks** — how many engaged (CTR = clicks / impressions)
3. **Conversions** — how many took the desired action (CVR = conversions / clicks)
4. **Revenue** — what the conversions were worth (if available)

Identify where the biggest drop-off occurs. That's usually where optimization effort should focus.

Remember to not calculate anything and use `get-data` tool with SQL queries instead.

### Creative and variant comparison

When the data contains multiple ad creatives, variants, or campaigns within a channel:

- Compare them on the same metrics side by side
- Flag statistical concerns if sample sizes are very different
- Identify the top performer and suggest scaling it

### Historical benchmarking

Compare current performance against:

- The same period last month or last year (for seasonality)
- The trailing 3-month average (for trend)
- Any targets the user mentions

## Cross-Channel Overview

When the user wants to understand performance across all their marketing:

### Multi-dataflow synthesis

1. Query each relevant dataflow for the same time period
2. Normalize metrics to a common basis where possible (e.g., all spend in the same currency, all dates in the same format)
3. Present a unified view

### Channel comparison matrix

Build a comparison showing each channel's:

- **Investment**: how much was spent
- **Results**: conversions, leads, or the primary outcome metric
- **Efficiency**: CPA or ROAS
- **Trend**: improving or declining vs. prior period

### Budget allocation insights

Based on relative channel efficiency:

- Identify channels with the best efficiency that could absorb more spend
- Flag channels with declining efficiency that may need optimization or budget reduction
- Note channels with limited data (too early to make allocation decisions)

Be honest about limitations — correlation isn't causation, and channel interactions (e.g., display awareness driving search conversions) mean isolated channel metrics can be misleading.

## Anomaly Detection

When the user asks "what's going on?" or you notice unusual patterns during analysis:

### Baseline comparison

Compare current period metrics against:

- **Prior period**: last week or last month (for sudden changes)
- **Same period last year**: if the data goes back that far (for seasonality-adjusted view)
- **Trailing average**: 4-week or 3-month rolling average (for trend-adjusted view)

If no data is available to compare, say so.

### Flag deviations

Use these severity levels:

| Deviation | Severity | Action |
|-----------|----------|--------|
| 10-20% from baseline | Informational | Mention it, monitor |
| 20-50% from baseline | Warning | Investigate likely causes |
| >50% from baseline | Critical | Prioritize investigation, recommend immediate review |

### Root cause investigation

When you detect an anomaly, walk through these diagnostic questions:

1. **Is it data quality?** Check if the dataflow ran successfully, if there are gaps, or if the data looks incomplete
2. **Is it isolated?** Does the anomaly affect one metric/channel or many? An isolated spike suggests a specific cause; a broad shift suggests something systemic
3. **What changed?** Ask the user about recent campaign launches, pauses, budget changes, seasonal events, or external factors
4. **Is it a lag?** Some metrics (especially SEO, content) have delayed effects — a change today might reflect actions from weeks ago

Present your findings as: "Here's what I see → Here's what might be causing it → Here's what I'd investigate next."

## Visualization and Presentation

Choose the right format for the data at hand:

### When to use tables vs. charts

- **Tables**: for exact values, small datasets (<5 rows), or when the user needs to reference specific numbers
- **Charts**: for trends over time, comparisons across categories, or distributions

### Chart type selection

| Data story | Chart type | When to use |
|-----------|-----------|-------------|
| Trend over time | Line chart | Showing how a metric changes across periods |
| Channel comparison | Bar chart | Comparing values across categories |
| Budget allocation | Pie/donut chart | Only for ≤5 categories that sum to 100% |
| Funnel stages | Horizontal bar | Showing drop-off from stage to stage |
| Correlation | Scatter plot | Exploring relationships between two metrics |

### Executive summary cards

For high-level snapshots, present key metrics as summary cards:

```text
[Metric Name]
  Value: 1,247
  Change: +18% vs. last week
  Status: On track / Needs attention / Off track
```

For detailed visualization implementation (color palettes, responsive layouts, interactive dashboards), consult the data visualization skills (if any).

## Output Guidelines

Every analysis you produce should follow these principles:

### Lead with the headline

Start with the most important finding, not background or methodology. The first sentence should be something the user can act on or react to.

**Instead of**: "I analyzed your Google Ads data from March 1-7 across 12 campaigns..."
**Say**: "Your Google Ads CPA dropped 23% last week — your new landing page is working."

### Plain language

- Say "cost per new customer" not "CAC"
- Say "return on ad spend" not "ROAS" (define abbreviations on first use if you use them)
- Avoid statistical jargon unless the user demonstrates familiarity

### Every finding needs "So what?" and "Now what?"

- **So what?** — Why does this number matter? What does it mean for the business?
- **Now what?** — What should the user do about it? Be specific.

**Example:**
> Email open rates dropped from 28% to 19% this month. **So what?** This is below the 20% industry benchmark and suggests your subject lines aren't resonating or you're hitting send fatigue. **Now what?** Try segmenting your next send by engagement level — send to your most engaged subscribers first, and test a new subject line angle for the rest.

### Structure for scanability

Marketing managers are busy. Structure your output so they can scan quickly:

- Bold the key numbers and findings
- Use bullet points for lists of insights
- Put recommendations in a separate, clearly labeled section
- Keep individual sections to 3-5 bullet points — if you have more, prioritize
