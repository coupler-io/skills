---
name: custom-dashboards
description: "Use this skill when the user wants a dashboard, report page or set of charts over their Coupler.io data, or wants to change an existing custom dashboard. Triggers include: 'build me a dashboard', 'chart my ad spend by week', 'make a report page for this dataset', 'add a filter to my dashboard', 'change the chart on my custom dashboard', 'show KPIs for my Stripe data'."
metadata:
  title: "Custom Dashboards"
  short_description: "Builds and edits interactive dashboards over your Coupler.io data, with KPIs, charts, tables and filters."
  category: capability
  sources: []
---

# Custom Dashboards

You build and edit custom dashboards in Coupler.io: interactive pages with KPIs, charts, tables and filters over the user's datasets. A dashboard is an [Evidence](https://docs.evidence.studio) project written in Markdoc. Coupler.io renders it, runs its SQL on the datasets and applies the Coupler.io layout and theme.

Tools: `list-custom-dashboards`, `get-custom-dashboard`, `create-custom-dashboard`, `update-custom-dashboard`, `delete-custom-dashboard`. If they're missing, custom dashboards aren't enabled for this user yet: say so and stop.

## Workflow

### Step 1: Pin down the question

Find out what the dashboard is for: the metrics, the breakdowns (by date, campaign, product…), the time range and the filters the user wants. If the request is vague, propose a short outline (3–6 KPIs, 2–4 charts, a table) and confirm it before building.

### Step 2: Find the data

1. Find the datasets with `list-datasets` or `search-datasets`. Use datasets that already exist; if the data isn't there, say so (setting up a dataflow is a separate task).
2. Read each dataset's columns with `get-schema`. Use each column's `columnName` in SQL, double-quoted when it has spaces or capitals (`"Campaign Name"`). Use the column descriptions for units and meaning (cents vs dollars, what `cost` covers).
3. When a value's meaning is unclear, check a few rows with `get-data` before charting it.

### Step 3: Write the dashboard

A dashboard has two inputs:

- `datasets`: table alias → dataset id, e.g. `{ "ppc": "<dataset id>" }`. Aliases are lowercase (`[a-z_][a-z0-9_]*`) and short. SQL reads a dataset as `from ppc`.
- `files`: path → content.
  - `pages/index.md` (required): the page. It's the only page.
  - `queries/<name>.sql` (optional): queries the page reuses, referenced inside a SQL block as `{{ "/queries/<name>" }}`.
  - Nothing else: the layout (full width, cards) and the theme are built in.

#### SQL rules

- The dialect is DuckDB.
- **Each SQL statement reads exactly one dataset.** No joins or unions across aliases. To compare datasets, chart them side by side; to combine them for real, the user needs a combined dataset in a Coupler.io dataflow.
- Name every SQL block (` ```sql daily `) and refer to it by that name. Names are unique in the page.
- Prefer one shared base query (`queries/<name>.sql`) that renames and casts columns once (short names, `cast(... as date)`, `coalesce` for nulls), then small page blocks on top of it.
- A block can reuse another block on the page with `{{<block name>}}`, which is substituted as a subquery in parentheses: `where category in (select category from {{top_categories}})`. Both blocks must read the same dataset.
- Aggregate in the component when you can (`y="sum(cost) as cost"`); the block can stay at row level.

#### Page structure

The page is Markdown: text, `##` headings, lists, **bold**, _italics_, `inline code` and [links](https://example.com) work as usual. SQL lives in named code fences, and components use [Markdoc](https://markdoc.dev/docs/syntax) tags (`{% tag ... /%}`).

````markdown
---
title: Ad spend
---

# Ad spend

What we spend, where, and what it brings.

```sql ads
select * from {{ "/queries/ads_base" }}
where {{period.filter}} and {{f_campaign.filter}}
```

```sql ads_all
select * from {{ "/queries/ads_base" }}
```

{% filter_bar %}
    {% range_calendar id="period" value_column="day" title="Period" default_range="last 90 days" /%}
    {% dropdown id="f_campaign" data="ads_all" value_column="campaign" title="Campaign" multiple=true /%}
{% /filter_bar %}

{% row %}
    {% big_value data="ads" title="Spend" value="sum(cost)" fmt="usd0" /%}
    {% big_value data="ads" title="Clicks" value="sum(clicks)" fmt="num0" /%}
    {% big_value data="ads" title="CPC" value="sum(cost) / nullif(sum(clicks), 0)" fmt="usd2" /%}
{% /row %}

## Over time

{% line_chart data="ads" title="Spend by week" x="day" date_grain="week" y="sum(cost) as cost" series="campaign" y_fmt="usd0" /%}

## Breakdown

{% row %}
    {% bar_chart data="ads" title="Spend by campaign" x="campaign" y="sum(cost) as cost" y_fmt="usd0" /%}
    {% pie_chart data="ads" title="Clicks by device" category="device" value="sum(clicks)" pct=true /%}
{% /row %}

{% table data="ads" title="Campaigns" page_size=20 %}
    {% dimension value="campaign" title="Campaign" /%}
    {% measure value="sum(cost) as cost" fmt="usd0" sort="desc" viz="bar" /%}
    {% measure value="sum(clicks) as clicks" fmt="num0" /%}
{% /table %}
````

With `queries/ads_base.sql`:

```sql
select
  cast("Date" as date) as day,
  coalesce("Campaign Name", '(not set)') as campaign,
  "Device" as device,
  "Cost" as cost,
  "Clicks" as clicks
from ppc
```

#### Components

In short (see **Component reference** at the end for when to use each one, with examples):

- `big_value`: one KPI. `value` is an aggregate; `info` adds a tooltip.
- `line_chart`, `bar_chart`: `x`, `y` (an aggregate with an alias), optional `series`, and `date_grain` (`day`, `week`, `month`, `quarter`, `year`) when `x` is a date column.
- `pie_chart`: `category`, `value`, optional `pct=true`.
- `table`: nested `dimension` and `measure` tags; `measure` takes `fmt`, `sort` and `viz="bar"`.
- `row`: puts components side by side (2–4 per row).
- `filter_bar`: holds `range_calendar` (dates, `value_column`) and `dropdown` (`data`, `value_column`, `multiple=true`). A block uses a filter with `where {{<id>.filter}}`. Feed dropdowns from an unfiltered block so their options don't shrink as filters change.
- Formats (`fmt`, `y_fmt`): `num0`, `num1`, `pct1`, `usd0`, `usd2`, `eur0`…

Keep it readable: a one-line intro under the title, `##` sections, KPIs first, then trends, then breakdowns, then a detail table.

### Step 4: Save and check

- New dashboard: `create-custom-dashboard` with `title`, `files` and `datasets`.
- Existing dashboard: read it with `get-custom-dashboard` first, then `update-custom-dashboard`. `files` replaces all files and `datasets` all aliases, so send every file and alias, not only the changed ones.
- If saving fails, the error names the file or dataset: fix it and save again.
- Give the user the `url` from the response, and summarize what's on the dashboard in a few lines.

## Common mistakes

- Joining two aliases in one statement: split it into two blocks, one per dataset.
- Guessing column names: take `columnName` from `get-schema`.
- Charting a text column as a date: cast it in the base query.
- Sending only the changed file on update: the other files are deleted.

## Component reference

The 20 components you'll use most, from the Evidence docs. Examples read a page block `orders` (order_date, channel, country, product, category, revenue, orders, customers, cost); use your own block and column names. Filters are passed to a component by id with `filters=["<id>"]`, or used in SQL with `{{<id>.filter}}`. Examples that pass `filters` assume the page defines those inputs: `date_filter` (range_calendar on order_date), `channel_filter` and `country_filter` (dropdowns); a filter id that no input on the page defines fails validation.

### KPIs

#### big_value

Use for a headline KPI card (one aggregated number) with optional comparison vs prior period/target and a sparkline; group several in a row. For a number inline in prose use value; for a small change indicator use delta; for a metric across many categories use a chart or heat_grid.

Minimal:

```markdoc
{% big_value
	data="orders"
	value="sum(revenue)"
/%}
```

Common:

```markdoc
{% big_value
	data="orders"
	value="sum(revenue)"
	title="Revenue"
	fmt="usd0"
	info="Gross revenue net of refunds"
	filters=["channel_filter"]
	date_range={
		date="order_date"
		range="last 12 months"
	}
	comparison={
		compare_vs="prior year"
		display_type="pct"
		text="vs last year"
	}
	sparkline={
		type="area"
		x="order_date"
		date_grain="month"
	}
/%}
```

#### delta

Use for an inline up/down change indicator (e.g. inside text or a table-like layout) comparing a value to a prior period, target or benchmark. For a headline KPI with its own comparison use big_value; for a plain number use value.

Minimal:

```markdoc
{% delta
	data="orders"
	value="sum(revenue)"
	comparison={
		compare_vs="prior period"
	}
/%}
```

Common:

```markdoc
Revenue this month changed {% delta
	data="orders"
	value="sum(revenue)"
	text="vs. prev month"
	chip=true
	filters=["channel_filter"]
	date_range={
		date="order_date"
		range="this month"
	}
	comparison={
		compare_vs="prior period"
		display_type="pct"
	}
/%}
```

### Charts

#### line_chart

Default choice for trends over time and for comparing a few series on a continuous x-axis; use y2 for a measure on another scale. For one headline number use big_value; for comparing categories use bar_chart; to mix bars and lines use combo_chart.

Minimal:

```markdoc
{% line_chart
    data="orders"
    x="order_date"
    y="sum(revenue)"
    date_grain="month"
/%}
```

Common:

```markdoc
{% line_chart
    data="orders"
    x="order_date"
    y="sum(revenue)"
    y2="sum(orders)"
    date_grain="week"
    date_range={ range="last 6 months" date="order_date" }
    filters=["channel_filter", "country_filter"]
    y_fmt="usd0"
    y2_fmt="num0"
    title="Weekly Revenue and Orders"
    subtitle="Revenue on the left axis, orders on the right"
    line_options={
        smooth=true
        markers={
            shape="circle"
            size=6
        }
    }
/%}
```

#### bar_chart

Use to compare an aggregate across categories or date buckets with vertical bars, optionally split by series (stacked, or stacked="100%" for share). For ranked lists or long labels use horizontal_bar_chart; for a continuous trend use line_chart; to mix bars with lines use combo_chart.

Minimal:

```markdoc
{% bar_chart
    data="orders"
    x="channel"
    y="sum(revenue)"
/%}
```

Common:

```markdoc
{% bar_chart
    data="orders"
    x="order_date"
    y="sum(revenue)"
    series="channel"
    date_grain="month"
    date_range={ range="last 6 months" date="order_date" }
    filters=["country_filter"]
    y_fmt="usd0"
    title="Monthly Revenue by Channel"
    subtitle="Stacked by acquisition channel"
    legend_location="bottom"
    tooltip_fields=[
        { value="sum(orders)" label="Orders" fmt="num0" },
        { value="sum(revenue) / nullif(sum(orders), 0)" label="Avg order" fmt="usd0" }
    ]
/%}
```

#### horizontal_bar_chart

Use to rank or compare categories with long labels (top products, countries), with the category on y and the value on x. For time on the axis or a few short labels use bar_chart.

Minimal:

```markdoc
{% horizontal_bar_chart
    data="orders"
    y="product"
    x="sum(revenue)"
/%}
```

Common:

```markdoc
{% horizontal_bar_chart
    data="orders"
    y="product"
    x="sum(revenue)"
    order="sum(revenue) desc"
    limit=10
    x_fmt="usd0"
    date_range={ range="last 30 days" date="order_date" }
    filters=["channel_filter"]
    title="Top 10 Products by Revenue"
    subtitle="Last 30 days"
    data_labels={
        position="right"
        fmt="usd0k"
    }
/%}
```

#### area_chart

Use for a trend over time where the filled area stresses volume, or where stacked series show how parts build a total (stacked="100%" shows share over time). For a plain trend or overlapping series use line_chart; for comparing categories use bar_chart.

Minimal:

```markdoc
{% area_chart
    data="orders"
    x="order_date"
    y="sum(revenue)"
    date_grain="month"
/%}
```

Common:

```markdoc
{% area_chart
    data="orders"
    x="order_date"
    y="sum(revenue)"
    series="channel"
    date_grain="month"
    date_range={ range="last 12 months" date="order_date" }
    filters=["country_filter"]
    y_fmt="usd0"
    title="Revenue by Channel"
    subtitle="Monthly, last 12 months"
    legend_location="bottom"
    area_options={
        smooth=true
        gradient=true
    }
/%}
```

#### combo_chart

Use to combine different series types (bar, line, area, scatter, bubble children) on one x-axis, usually with a second y-axis via axis="y2" (e.g. revenue bars with an orders line). For a single series type use bar_chart, line_chart or area_chart, which also accept y2.

Minimal:

```markdoc
{% combo_chart data="orders" x="order_date" date_grain="month" %}
    {% bar y="sum(revenue)" /%}
    {% line y="sum(orders)" axis="y2" /%}
{% /combo_chart %}
```

Common:

```markdoc
{% combo_chart
    data="orders"
    x="order_date"
    date_grain="month"
    date_range={ range="last 12 months" date="order_date" }
    filters=["channel_filter"]
    y_fmt="usd0"
    y2_fmt="num0"
    title="Revenue and Orders"
    subtitle="Monthly revenue (bars) vs. order count (line)"
%}
    {% bar y="sum(revenue)" fmt="usd0" /%}
    {% line y="sum(orders)" axis="y2" fmt="num0" options={type="dashed" width=2} /%}
{% /combo_chart %}
```

#### pie_chart

Use for part-to-whole share across a small number of categories; it draws a donut by default (inner_radius="0%" for a full pie). For many categories or precise comparison use bar_chart or horizontal_bar_chart; for nested parts use treemap.

Minimal:

```markdoc
{% pie_chart
    data="orders"
    category="channel"
    value="sum(revenue)"
/%}
```

Common:

```markdoc
{% pie_chart
    data="orders"
    category="channel"
    value="sum(revenue)"
    value_fmt="usd0"
    pct=true
    pct_fmt="pct1"
    date_range={ range="this quarter" date="order_date" }
    filters=["country_filter"]
    title="Revenue Share by Channel"
    subtitle="This quarter"
/%}
```

#### scatter_chart

Use to show the relationship between two aggregated measures, one point per series or point_title group (e.g. cost vs. revenue per product). For a third measure as point size use bubble_chart; for trends over time use line_chart.

Minimal:

```markdoc
{% scatter_chart
    data="orders"
    x="sum(cost)"
    y="sum(revenue)"
    series="channel"
/%}
```

Common:

```markdoc
{% scatter_chart
    data="orders"
    x="sum(cost)"
    y="sum(revenue)"
    series="category"
    point_title="product"
    x_fmt="usd0"
    y_fmt="usd0"
    date_range={ range="last 12 months" date="order_date" }
    title="Revenue vs. Cost by Product"
    subtitle="Each point is a product, coloured by category"
/%}
```

#### funnel_chart

Use to show how a count shrinks through ordered stages (e.g. sessions to carts to orders), with show_percent for conversion from the first stage. The data needs a stage column; for unordered category comparisons use bar_chart, and for flows that branch use sankey_chart.

Minimal:

```markdoc
{% funnel_chart
    data="checkout_funnel"
    category="stage"
    value="sum(sessions)"
/%}
```

Common:

```markdoc
<!-- checkout_funnel: SQL block with one row per stage and day: stage, sessions -->
{% funnel_chart
    data="checkout_funnel"
    category="stage"
    value="sum(sessions)"
    value_fmt="num0"
    show_percent=true
    align="center"
    label_position="outside"
    gap=4
    filters=["channel_filter"]
    title="Checkout Funnel"
    subtitle="Share of sessions reaching each stage"
/%}
```

### Tables

#### table

Use to show aggregated numbers by one or more groupings, cross-tabs (with pivot), or comparisons and in-cell viz, built from dimension/measure/pivot children. For one KPI use big_value; for trends over time prefer line_chart or bar_chart.

Minimal:

```markdoc
{% table data="orders" %}
    {% dimension value="channel" /%}
    {% measure value="sum(revenue)" /%}
{% /table %}
```

Common:

```markdoc
{% table
    data="orders"
    title="Revenue by Channel and Country"
    subtitle="Last 12 months"
    filters=["date_filter", "channel_filter"]
    search=true
    page_size=25
    collapsible=true
    freeze_columns=1
%}
    {% dimension value="channel" /%}
    {% dimension value="country" /%}
    {% measure value="sum(orders)" title="Orders" fmt="num0" /%}
    {% measure
        value="sum(revenue)"
        title="Revenue"
        fmt="usd0"
        viz="bar"
        sort="desc"
    /%}
    {% measure
        value="sum(revenue) / sum(orders) as aov"
        title="AOV"
        fmt="usd2"
    /%}
{% /table %}
```

#### pivot

Use inside `table` to spread a column's values across columns (e.g. years or channels as column headers) for a cross-tab. Needs at least one measure. For row groupings use `dimension`; for charts over time prefer a line or bar chart.

Minimal:

```markdoc
{% table data="orders" %}
    {% dimension value="category" /%}
    {% pivot value="order_date" date_grain="year" /%}
    {% measure value="sum(revenue)" /%}
{% /table %}
```

Common:

```markdoc
{% table
    data="orders"
    title="Revenue by Category and Quarter"
    show_total_column=true
%}
    {% dimension value="category" /%}
    {% pivot
        value="order_date"
        date_grain="quarter"
        sort="asc"
    /%}
    {% measure value="sum(revenue)" fmt="usd0" /%}
{% /table %}
```

### Filters

#### filter_bar

Wrap page-level filter inputs (dropdown, button_group, range_calendar, date_grain_selector, comparison_selector, period_selector, table_filter, toggle, text_input, slider) in a floating bar at the top or bottom of the page. It has no attributes; leave single inline filters outside it.

Minimal:

```markdoc
{% filter_bar %}
    {% range_calendar id="date_filter" /%}
{% /filter_bar %}
```

Common:

```markdoc
{% filter_bar %}
    {% range_calendar
        id="date_filter"
        value_column="order_date"
        default_range="last 30 days"
    /%}
    {% dropdown
        id="channel_filter"
        data="orders"
        value_column="channel"
        title="Channel"
    /%}
    {% date_grain_selector
        id="time_grain"
        default_value="week"
    /%}
{% /filter_bar %}

{% line_chart
    data="orders"
    x="order_date"
    y="sum(revenue)"
    date_grain={{time_grain}}
    filters=["date_filter", "channel_filter"]
/%}
```

#### range_calendar

Date range picker with presets (last 30 days, year to date, ...) and custom named ranges; pass to components via date_range={ range={{id}} }, or set value_column and use filters / {{id.filter}}. To step through whole calendar periods use period_selector; to change grouping grain use date_grain_selector.

Minimal:

```markdoc
{% range_calendar id="date_filter" /%}
```

Common:

```markdoc
{% range_calendar
    id="date_filter"
    title="Order Date"
    value_column="order_date"
    default_range="last 3 months"
    preset_ranges=["last 7 days", "last 30 days", "last 3 months", "year to date", "all time"]
/%}

{% big_value
    data="orders"
    value="sum(revenue)"
    fmt="usd0"
    filters=["date_filter"]
/%}

{% line_chart
    data="orders"
    x="order_date"
    y="sum(revenue)"
    date_grain="week"
    date_range={
        date="order_date"
        range={{date_filter}}
    }
/%}
```

#### dropdown

Default filter input: a searchable select populated with distinct values from a column (data + value_column) or option children; supports multi-select, cascading via filters, and is referenced by id in filters, where or SQL. For 2-6 values button_group is more visible; for dates use range_calendar; for free text use text_input.

Minimal:

```markdoc
{% dropdown
    id="country_filter"
    data="orders"
    value_column="country"
/%}
```

Common:

```markdoc
{% dropdown
    id="channel_filter"
    data="orders"
    value_column="channel"
    title="Channel"
/%}

{% dropdown
    id="country_filter"
    data="orders"
    value_column="country"
    title="Country"
    multiple=true
    default_top_n=5
    order="country"
    filters=["channel_filter"]
    date_range={
        date="order_date"
        range="last 12 months"
    }
/%}

{% bar_chart
    data="orders"
    x="country"
    y="sum(revenue)"
    y_fmt="usd0"
    filters=["channel_filter", "country_filter"]
/%}
```

#### button_group

Segmented buttons to pick one (or with multiple=true, several) of a few values, either distinct values from a column (data + value_column) or hardcoded option children; reference it by id in filters, where or SQL. Best for short lists of 2-6 values; for long lists use dropdown, and for full-width tab navigation use input_tabs.

Minimal:

```markdoc
{% button_group
    id="channel_filter"
    data="orders"
    value_column="channel"
/%}
```

Common:

```markdoc
{% button_group
    id="channel_filter"
    data="orders"
    value_column="channel"
    title="Channel"
    order="channel"
    select_first=true
/%}

{% bar_chart
    data="orders"
    x="order_date"
    y="sum(revenue)"
    y_fmt="usd0"
    date_grain="month"
    filters=["channel_filter"]
/%}
```

#### date_grain_selector

Let viewers switch the time bucket (day, week, month, ...) of time-series charts by passing date_grain={{id}}, or date_trunc({{id}}, ...) in SQL. To pick a date window use range_calendar or period_selector instead.

Minimal:

```markdoc
{% date_grain_selector id="time_grain" /%}
```

Common:

```markdoc
{% date_grain_selector
    id="time_grain"
    default_value="month"
    preset_values=["week", "month", "quarter"]
    title="Group by"
/%}

{% line_chart
    data="orders"
    x="order_date"
    y="sum(revenue)"
    y_fmt="usd0"
    date_grain={{time_grain}}
/%}
```

### Layout

#### row

Use to place components side by side, e.g. several KPIs, two charts, or a heading with a filter or button on the right. Items stretch to share width and wrap on narrow screens. For vertical grouping use stack; for switchable views use tabs.

Minimal:

```markdoc
{% row %}
    {% big_value data="orders" value="sum(revenue)" /%}
    {% big_value data="orders" value="sum(orders)" /%}
{% /row %}
```

Common:

```markdoc
{% row align="center" justify="between" %}
## Revenue by Category
{% dropdown id="channel_filter" data="orders" value_column="channel" /%}
{% /row %}

{% row card=true %}
    {% big_value data="orders" value="sum(revenue)" fmt="usd0" title="Revenue" filters=["channel_filter"] /%}
    {% big_value data="orders" value="sum(orders)" fmt="num0" title="Orders" filters=["channel_filter"] /%}
    {% big_value data="orders" value="sum(revenue) / sum(orders)" fmt="usd0" title="Avg Order Value" filters=["channel_filter"] /%}
{% /row %}
```

#### tabs

Use to let viewers switch between alternative views of the same topic (e.g. revenue by channel vs by country) without lengthening the page. Children must be tab components. For side-by-side comparison use row; for hidden detail behind a button use modal.

Minimal:

```markdoc
{% tabs %}
	{% tab title="Tab 1" %}
		Content for tab 1
	{% /tab %}
	{% tab title="Tab 2" %}
		Content for tab 2
	{% /tab %}
{% /tabs %}
```

Common:

```markdoc
{% tabs variant="well" full_width=true %}
	{% tab title="Revenue" icon="trending-up" default=true %}
		{% line_chart
			data="orders"
			x="order_date"
			y="sum(revenue)"
			date_grain="month"
		/%}
	{% /tab %}
	{% tab title="Customers" icon="users" %}
		{% line_chart
			data="orders"
			x="order_date"
			y="sum(customers)"
			date_grain="month"
		/%}
	{% /tab %}
{% /tabs %}
```

#### callout

Use to highlight a message, note or warning in a colored box (type info, success, warning, error). For collapsible explanatory text use `details`; for user-entered notes use `commentary`.

Minimal:

```markdoc
{% callout %}
This is an info callout.
{% /callout %}
```

Common:

```markdoc
{% callout type="warning" title="Data Freshness" %}
Orders from the last 24 hours may still be syncing; revenue for today is incomplete.
{% /callout %}
```
