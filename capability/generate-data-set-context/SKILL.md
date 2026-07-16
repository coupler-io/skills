---
name: generate-data-set-context
description: "Use this skill when the user wants to explore a dataset's context, or write or update documentation for the data it holds. Triggers include: 'explore this data set', 'document this data flow', 'generate dataset documentation', 'update data set context', 'what's in this dataset', 'add context to my data'."
---

# Generate Data Set Context

You are a data analyst with access to the **Coupler.io MCP** server. Your task is to explore a Coupler.io data flow and produce a complete dataset documentation file in markdown.

## Inputs

Ask the user for:

1. **Data flow name** — the name shown in Coupler.io (or a keyword to search for).
   If provided with a data flow ID directly, skip straight to exploring the schema.

## Coupler MCP workflow

All data access goes through the **Coupler.io MCP** server. The tool sequence is:

1. `search-datasets` (or `list-datasets`) — find the dataflow by name or keyword
2. `get-dataflow` — fetch the dataflow's current state (sources, destinations, last run)
3. `get-schema` — inspect column definitions for the target dataset
4. `get-data` — query the data with SQL against the `data` table
5. `update-dataset` — persist `aiContext` on the dataset after generation

### SQL basics

- The table is always called **`data`**. Columns are named `col_0`, `col_1`, …
- Metric columns can be NULL. Use `COALESCE(col_X, 0)` as needed.

The profiling steps below will detect which additional conventions (string quoting, missing-value sentinels, fractional metrics, sign conventions) apply to this specific dataset.

## Step-by-step procedure

### 1. Explore the data flow

Use the Coupler MCP to find the data flow, fetch its schema, and sample the data. Do **not** include execution IDs in the output — they change every run.

### 2. Profile the data

#### 2a. Sample

SELECT * FROM data LIMIT 5

#### 2b. Detect conventions

- **String quoting:** inspect a text column value — are strings wrapped in embedded double quotes (`"India"`) or stored plain (`India`)?
- **Missing values:** check whether missing values appear as SQL NULLs or as a literal sentinel string (e.g. `"N/A"` or `N/A`).

#### 2c. Detect grain and duplication

SELECT COUNT(*) AS rows, COUNT(DISTINCT {pk_col}) AS distinct_keys FROM data
If rows >> distinct_keys, the dataset has row duplication (e.g. multi-value columns flattened into separate rows). Document how to deduplicate.

#### 2d. Profile categorical / dimensional columns

For each categorical column, decide based on the sample whether querying it will reveal something new:

- **Skip** if the column is a high-cardinality identifier or free-text field (the GROUP BY would return near-unique rows).
- **Skip** if the sample already shows all plausible values (the full value set is evident).
- **Skip** date/timestamp columns entirely.
- **Query** everything else:
SELECT {col_N}, COUNT(*) AS cnt FROM data GROUP BY {col_N} ORDER BY cnt DESC LIMIT 15

#### 2e. Profile numeric / metric columns

For each numeric column, decide based on the sample whether querying it will reveal something new:

- **Skip** if the column's meaning, scale, and sign are already clear from the sample values.
- For groups of closely related numeric columns, **query one representative**; skip the rest if it behaves as expected.
- **Query** everything else. Combine multiple columns into a single query to reduce round-trips:
SELECT COUNT(*) AS rows,
SUM({col_A}) AS total_a, MIN({col_A}) AS min_a, MAX({col_A}) AS max_a,
SUM({col_B}) AS total_b, MIN({col_B}) AS min_b, MAX({col_B}) AS max_b
FROM data

**Important:** profiling numbers (row counts, totals, percentages, date ranges) are for your understanding only. Do **not** write them into the output — they go stale as the data changes.

### 3. Discover domain context

Profiling in step 2 exists to inform the domain context — NOT to produce a column listing. Do not replicate column names, types, or labels in the output. `get-schema` already exposes all of that to downstream consumers.

Investigate and document the following (where applicable):

- **Business process:** what real-world process does this data represent?
- **Deduplication:** are there multi-value or array columns that produce multiple rows per entity? What is the correct way to deduplicate?
- **Attribution:** are values only populated on certain rows due to attribution logic? What determines which row gets credit?
- **Sentinel values:** are there business-logic defaults that look like real data (e.g. a $150 placeholder value)?
- **Hidden columns:** are there columns in the source query that are excluded from the Coupler export?
- **Scope / time window:** does the pipeline apply filters that limit the data (e.g. rolling window, status filters)?
- **Sign conventions:** are any numeric columns stored with inverted sign (e.g. churn as negative)?

If you cannot determine some of these from the data alone, mark them with `{TODO: verify with team}` so the user knows where to fill in.

### 4. Write the dataset documentation

Produce the markdown document following the **Output structure** below. Do **not** embed volatile numbers (row counts, totals, percentages, date ranges). Do **not** list columns, types, or schema — that information lives in `get-schema` and would duplicate it.

---

## Output structure

The output document must follow this structure exactly.

````markdown
# {Dataset title}

{One-paragraph description: what this dataset contains, its purpose, and scope.}

## Domain context

{Business knowledge that helps analysts interpret the data correctly.
Fill in what applies — remove bullet points that don't.}

- **Business process:** {What real-world process does this data represent?}
- **Grain:** {What does one row represent?}
- **Key caveats:**
  - {Deduplication rules, if applicable.}
  - {Attribution logic, if applicable.}
  - {Sentinel values, if applicable.}
  - {Hidden columns, if applicable.}
  - {Scope / time window, if applicable.}
  - {Sign conventions, if applicable.}

## SQL conventions

- {String quoting convention observed in this dataset.}
- {Missing-value handling observed in this dataset.}
- {Any other dataset-specific SQL quirks discovered during profiling.}
````
