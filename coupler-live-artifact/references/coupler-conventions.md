# Coupler.io conventions and gotchas

Concrete things to know before writing SQL or wiring MCP calls. Read this before Step 4 of SKILL.md.

## Column naming

Coupler exposes columns as `col_0`, `col_1`, ..., `col_N` regardless of source. The human-readable column name lives in the `label` field of the schema. The table is always called `data`. There is no schema- or database-qualified prefix.

When writing SQL: refer to columns as `col_N`. When displaying results: map back to the labels from `get-schema`.

## String columns: quoting convention varies — probe every snapshot

**The single biggest trap.** Coupler's storage layer sometimes wraps string values in embedded double quotes and sometimes does not. The convention can change between snapshots of the same dataflow with no schema change. Observed in the wild: the Templates Funnel dataflow stored `col_1 = '"Looker Studio"'` (quoted) for months, then a refresh later returned `col_1 = 'Looker Studio'` (unquoted). Every SQL filter built against the old convention silently matched zero rows.

**Always probe** before writing SQL against a new snapshot:

```sql
SELECT * FROM data LIMIT 1
```

Look at the actual string values. If they begin and end with `"`, the convention is quoted — build filters as `col_X = '"value"'`. If not, build filters as `col_X = 'value'`. Don't trust prior runs or the `ai_context` description on this point.

**Defense-in-depth**: write filters that match **either** convention:

```sql
WHERE col_1 IN ('Looker Studio', '"Looker Studio"')
```

This costs nothing and survives convention flips. Apply the same idea to date columns and category `LIKE` patterns.

**Original (legacy) note for context:** When values do have embedded quotes, a column whose label says "Looker Studio" stores as the literal seven-character string `"Looker Studio"`.

Implications:

**SQL filters must include the quotes.** This is wrong:

```sql
WHERE col_1 = 'Looker Studio'   -- matches nothing
```

This is right:

```sql
WHERE col_1 = '"Looker Studio"'  -- matches
```

Building filter values from variables:

```js
const value = "Looker Studio";
const sql = `WHERE col_1 = '"${value}"'`;
```

**`LIKE` patterns must include the quotes too**, or use them at the boundaries of comma-separated multi-value cells. For category cells like `col_3 = '"Marketing,SEO"'`:

```sql
-- Match category "Marketing" anywhere in the comma list
WHERE col_3 LIKE '%"Marketing"%' OR col_3 LIKE '%,Marketing,%'
   OR col_3 LIKE '%"Marketing,%' OR col_3 LIKE '%,Marketing"%'
```

**Display layer must strip the outer quotes** before showing values to users. Use `stripQuotes` from the snippets file.

**Date-formatted columns store the same way.** Dates appear as `'"2026-05-01"'`, not `'2026-05-01'`. Same SQL escaping rules apply.

## NULLs in metric columns

Most numeric columns are nullable. `SUM(col_N)` over a partition that has any NULL behaves correctly in SQLite (NULLs are skipped), but `col_N + col_M` does not — any NULL operand poisons the expression.

Always wrap metrics in `COALESCE(col_N, 0)` when summing or comparing. The schema's `ai_context` typically reminds you of this.

## Verify the stated grain — don't trust it

The `ai_context` block usually claims a grain like "one row per template × month". This claim is sometimes wrong. The Templates Funnel dataflow at Coupler.io advertises template × month grain but actually has template × short_link × month — same `template_id` appears multiple times per month when a template has multiple short links.

Before writing any leaderboard or per-entity query, run:

```sql
SELECT col_<id_column>, col_<time_column>, COUNT(*) AS cnt
FROM data
GROUP BY col_<id_column>, col_<time_column>
HAVING cnt > 1
LIMIT 5
```

If this returns rows, the real grain is finer than the advertised grain. Your aggregation queries must `GROUP BY` the entity ID and `SUM()` everything, not select raw rows.

If you select raw rows when grain is finer than expected, the user sees duplicates with split metrics. The fix is to group-and-sum.

## `ai_context` is gold — read it carefully

The `ai_context` field on `get-schema` is a markdown blob written by the dataflow author. It typically contains:

- Domain context (what the data represents, what the business process is)
- Caveats (NULL semantics, deduplication, attribution windows)
- Dataset connection details (dataflow ID, source, schedule)
- SQL conventions (column naming, value-quoting reminders)
- Suggested queries for common analyses

Always read it end-to-end before writing SQL. It saves a lot of guessing. When something seems weird in the data, re-read `ai_context` — the answer is usually documented.

## MCP tool quirks (Coupler client)

These are real validator/behavior quirks observed in the Cowork widget runtime, not in tool descriptions:

- **`search-datasets`** requires at least one of `query`, `source`, or `name`. Passing only `dataflowId` returns: `"Invalid parameters for search-datasets tool. Validation error: At least one of query, source, or name must be provided"`.
- **`list-datasets`** accepts `dataflowId` alone. This is the right tool for snapshot lookup.
- **`get-dataflow`** does **not** include `last_dataset_snapshot_id`. It returns `id`, `name`, `sources`, `destinations` only. Do not use it to resolve snapshots.
- **`run-dataflow`** triggers asynchronously. It returns when the run is queued, not when it's complete. To know when fresh data is available, poll `list-datasets` and watch for `last_dataset_snapshot_id` to change.
- **Snapshot IDs rotate.** Each successful run produces a new `last_dataset_snapshot_id`. Hardcoding a snapshot is always wrong.

## MCP response shapes in the widget runtime

Same tool, different response shapes depending on the runtime:

- **Chat-side tool calls** typically return parsed JSON directly (e.g. `{datasets: [...]}` or `[...rows]`).
- **Widget-side `window.cowork.callMcpTool`** wraps results as content blocks: `{content:[{type:"text",text:"<JSON>"}],isError:false}`.
- **Some Coupler tools prefix prose to the JSON.** `list-datasets` returns content text like `"Total datasets: 1\n\n[...]"`. A naïve `JSON.parse(content[0].text)` fails.

Solution: use the tolerant parser in `references/snippets.js`. It tries direct JSON, content-block extraction, prose-prefixed extraction (find the first `[` or `{` and parse everything from there to the end).

## Funnel ordering is dataflow-specific

The Templates Funnel funnel order is `views → clicks → setup_started → activated → purchased`. Don't assume this for other dataflows. Confirm with the user or read the `ai_context` carefully — the column names are not always self-explanatory (e.g. `col_paid` may exist as a separate dimension and not be part of the linear funnel at all).

## Filter values: enumerate at build time

Pulling distinct values for a filter dropdown via the widget is slow and pointless when the enum is small and stable. Run `SELECT DISTINCT col_X FROM data` once at build time (in chat), hard-code the values into a JS array in the widget, and use them as dropdown options. If the enum can grow over time, add a comment in the SKILL or in the artifact noting how to refresh it.
