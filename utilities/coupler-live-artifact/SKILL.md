---
name: coupler-live-artifact
description: Build a live Cowork artifact (persistent HTML widget) backed by a Coupler.io dataflow. Use this skill whenever the user wants a live dashboard, persistent widget, daily-check page, or interactive explorer over Coupler.io data — including phrases like "live artifact for Coupler", "Coupler dashboard widget", "build a widget over a Coupler dataset", "Coupler.io live dashboard", "build a daily dashboard from a Coupler dataflow", or any time they ask to render Coupler data in a re-openable view that auto-refreshes. Triggers even when the user does not say "skill" or "artifact" but describes the same outcome (e.g. "I want a page I can check every morning that pulls my Coupler data").
---

# Coupler.io live artifact

A live artifact is a self-contained HTML page registered with Cowork that persists across sessions and re-fetches data from MCP connectors every time it opens. This skill covers the specific pitfalls of wiring one to a Coupler.io dataflow. Most generic widget guidance (CDN allowlist, sandboxing) lives in Cowork's `create_artifact` tool description — read that first. This skill captures the Coupler-specific traps that cost real time the first time someone hits them.

## When to use

The user wants a re-openable view over Coupler.io data: KPIs, funnel, leaderboard, time series, comparison. They have an existing dataflow or are pointing at a data set in their Coupler workspace. The output is a `.html` file registered via `mcp__cowork__create_artifact`.

## Process

### Step 1 — Probe in chat first

Before writing a single line of HTML, run these chat-side calls and read the output. All Coupler operations go through the single dispatcher tool `coupler`: `coupler({verb: "call", name: "<operation>", args: {...}})`. Args are snake_case.

1. `search-datasets({query: "<dataflow name>"})` to find the `dataflow_id`, `last_dataset_snapshot_id`, and the dataset `id`.
2. `get-schema({dataset_snapshot_id})` and **read `ai_context` carefully**. It documents column meanings, the funnel order, the SQL conventions, and known caveats. Most pitfalls are flagged here.
3. `get-data({dataset_snapshot_id, query: "SELECT * FROM data LIMIT 3"})` to see the actual row shape. Confirm what the schema claims.
4. `get-data({dataset_snapshot_id, query: "SELECT DISTINCT col_X FROM data ORDER BY col_X"})` for any column you intend to expose as a filter dropdown — pre-compute the full enum.
5. **Verify the stated grain.** The schema's `ai_context` often claims one row per `(entity × time)`, but real data sometimes has finer grain. Run:
   ```sql
   SELECT col_<id>, col_<time>, COUNT(*) cnt FROM data GROUP BY col_<id>, col_<time> HAVING cnt > 1 LIMIT 5
   ```
   If this returns rows, the grain is finer than advertised — the leaderboard query must `GROUP BY <id>` and `SUM(...)` everything, otherwise duplicates show up.

Read `references/coupler-conventions.md` once before writing SQL. It encodes Coupler's column/value conventions you will hit immediately.

### Step 2 — Decide the refresh strategy

Two modes, pick by how stale the user can tolerate:

| Mode | Behavior | Latency | When to use |
|---|---|---|---|
| **Live snapshot** (default) | Each artifact open calls `list-datasets({dataflow_id})`, takes `last_dataset_snapshot_id`, queries with `get-data`. | Fast (~1 RTT). | Daily checks, dashboards, any case where the user is fine with the last scheduled run. |
| **Forced refresh** (button) | Manual button calls `run-dataflow({dataflow_id})`, polls `list-datasets` every 5 s for up to 5 min until snapshot ID changes, then re-queries. | 30 s – several min. | "I want fresh data right now" buttons. Never on every page load — too slow and wasteful. |

Default to live-snapshot for load. Add a "Refresh data" button for forced refresh. Show `last_success_run_at` ("Last run: 5h ago") in the header so the user knows how stale things are.

### Step 3 — Pick widget MCP tools

Only list MCP tools you actually call from the widget in the `mcp_tools` parameter of `create_artifact`. There is a single Coupler tool — the dispatcher:

- `mcp__b2221b32-5723-40e6-b17d-a36abcd4c057__coupler` — list it once in `mcp_tools`; it covers all operations.

Widget-side calls take the form:

```js
window.cowork.callMcpTool("mcp__b2221b32-5723-40e6-b17d-a36abcd4c057__coupler",
  { verb: "call", name: "list-datasets", args: { dataflow_id: DATAFLOW_ID } })
```

Operations the widget uses: `list-datasets` (snapshot lookup — accepts `dataflow_id` alone), `get-data` (runs SQL), `run-dataflow` (only if a refresh button exists).

Do **not** use:
- `search-datasets` with only `dataflow_id` — its validator rejects this and returns "At least one of query, source, or name must be provided".
- `get-dataflow` for snapshot lookup — it returns config (sources/destinations) only, no snapshot ID.

### Step 4 — Write the artifact HTML

Start from `references/widget-template.html` — it's a minimal working scaffold with the right boilerplate (Chart.js CDN tag, snapshot lookup, `localStorage` filter persistence, light-mode styling).

Required helpers (in `references/snippets.js`, copy-paste into the artifact):

1. **Tolerant MCP response parser.** Widget-side `callMcpTool` wraps results inconsistently — sometimes direct JSON, sometimes `{content:[{type:"text",text:"..."}]}`, sometimes prose-prefixed text like `"Total datasets: 1\n\n[...]"`. Use the snippet's `parseToolResult` + `tryJsonFromText` — they handle all variants.
2. **Timezone-safe month strings.** Never use `new Date(y, m, 1).toISOString().slice(0, 10)` — for users east of UTC it returns the previous day, silently producing zero-row queries. Use the snippet's `monthFirst` / `prevMonthFirst`.
3. **Quote stripping.** Coupler stores string columns with embedded double quotes (e.g. `col_1 = '"Looker Studio"'`). SQL `WHERE` matches must include the quotes; display layer must strip them. Use the snippet's `stripQuotes` for display, and quote values in SQL like `col_1 = '"${value}"'`.
4. **Run-and-poll.** If the widget has a refresh button, copy the snippet's `refreshData` flow.
5. **Chart.js canvas wrapping.** With `responsive: true, maintainAspectRatio: false`, every `<canvas>` must sit inside a parent with explicit height (e.g. `<div style="position:relative;height:260px;width:100%"><canvas/></div>`). Without it, Chart.js silently collapses the canvas and renders a broken-image icon.
6. **Allowed CDN libs only.** Chart.js, Grid.js, Mermaid — exact tags from Cowork's `create_artifact` description (with `integrity` and `crossorigin`). Anything else must be inlined.
7. **`localStorage` for filter/sort state.** Persist the user's dropdown selections and sort order between opens — that's what makes a daily-check view feel right.

### Step 5 — Verify in the widget runtime

Probing in chat verifies data shape but **not** widget-runtime behavior. The two failure modes that are invisible to chat-side testing:

- **MCP-wrapper shape differences** — same tool returns one shape in chat, another shape (often prose-prefixed text) in widgets.
- **Timezone bugs** — `new Date(...).toISOString()` behaves differently per user, and the symptom is silent zeros, not an error.

After registering the artifact, verify the rendered widget shows non-zero values for a known-populated month. If KPIs all read 0, suspect the timezone bug or the quote convention before suspecting the data.

### Step 6 — Register the artifact

```
mcp__cowork__create_artifact({
  id: "<kebab-slug>",
  html_path: "<absolute path to the .html in outputs>",
  description: "<one-line summary of what it shows>",
  mcp_tools: ["mcp__b2221b32-5723-40e6-b17d-a36abcd4c057__coupler"]
})
```

For updates: `mcp__cowork__update_artifact({id, html_path, update_summary})`. Include a real `update_summary` — it's shown to the user in the approval prompt.

## Rules & Edge Cases

- **Always read `ai_context` from `get-schema` before writing SQL.** It documents column quote conventions, the funnel order, and known caveats. Skipping this step is the most common time-waster.
- **Verify dataset grain with a `GROUP BY ... HAVING COUNT(*) > 1` probe.** Don't trust the schema's stated grain. If the real grain is finer than advertised, your leaderboard will show duplicates.
- **Never hardcode `dataset_snapshot_id`.** It rotates on every dataflow run. Always resolve via `list-datasets({dataflow_id})` (through the dispatcher) at load time.
- **Default to live-snapshot loads, gate `run-dataflow` behind an explicit button.** Triggering a fresh run on every artifact open turns a 1-second load into a 1-minute load. Users will hate it.
- **Coupler's string-quoting convention is not stable.** Some dataflows/snapshots store strings with embedded double quotes (`col_X = '"Looker Studio"'`), others do not (`col_X = 'Looker Studio'`). The convention can flip between snapshots of the same dataflow. Always probe `SELECT * FROM data LIMIT 1` and look at the actual values before writing SQL filters. Defense in depth: write filters that match both conventions, e.g. `col_X IN ('value', '"value"')`. Keep `stripQuotes` on the display layer as a no-op safety net.
- **Build YYYY-MM-01 strings manually.** Never via `toISOString()`. Use `${y}-${String(m+1).padStart(2,"0")}-01`. The timezone bug is silent — it produces zero-row queries, not errors.
- **Chart.js canvases need a fixed-height parent.** Wrap every `<canvas>` in `<div style="position:relative;height:Npx;width:100%">`. Otherwise canvases collapse to 0 and you get a broken-image fallback.
- **Only the CDN libs listed in the `create_artifact` tool description load.** Chart.js, Grid.js, Mermaid. Use the exact `<script>` tags including `integrity` and `crossorigin`. Other CDNs are blocked.
- **The widget runs in light mode.** Set `:root { color-scheme: light }` and use a light background with dark text.
- **All Coupler operations go through the `coupler` dispatcher.** `mcp_tools` lists only the dispatcher tool; widget calls pass `{verb: "call", name, args}` with snake_case args. The operation set can change — discover via `{verb: "tools"}` rather than trusting memory. The dispatcher's widget-runtime response wrapping has not been end-to-end verified; the tolerant parser in `references/snippets.js` is designed to absorb extra wrapping, but the first artifact built against the dispatcher must complete the Step 5 verification.
- **`mcp_tools` array must list every tool the widget actually calls** (for Coupler, that is just the dispatcher). Tools not listed will fail at runtime.
- **Filter dropdown values: pre-compute, don't query in the widget.** Pulling distinct values is slow and pointless when you already know the enum at build time.
- **End-to-end widget verification is not optional.** Probe-in-chat catches data-shape bugs but misses widget-wrapper and timezone bugs. Always reload the rendered widget once and confirm non-zero values for a known-populated period.
- **`table-layout: fixed` collapses `auto`-width columns when other columns sum near the table width.** If a column needs to be flexible but visible, give it an explicit width (e.g. `280px`), not `auto`. Wrap the table in `overflow-x:auto` as a fallback.

## Reference files

- `references/coupler-conventions.md` — Coupler quote convention, grain caveats, ai_context tips, MCP tool quirks. Read before writing SQL.
- `references/snippets.js` — Drop-in helpers: `parseToolResult`, `tryJsonFromText`, `monthFirst`, `prevMonthFirst`, `stripQuotes`, `runQuery`, `fetchSnapshotInfo`, `refreshData`. Copy what you need into the artifact.
- `references/widget-template.html` — Minimal working scaffold (snapshot lookup, KPI cards, Chart.js, localStorage state, refresh button). Start here for new artifacts.

## Self-improvement

When the user flags a new Coupler quirk or widget-runtime gotcha, append it to `Rules & Edge Cases`. When the user approves a finished artifact that demonstrates a useful pattern (e.g. a clean way to render a stacked-bar funnel with destination breakdown), copy it to `references/examples/<descriptive-name>.html` for future runs to anchor on.
