// Drop-in helpers for Coupler.io-backed Cowork live artifacts.
// Copy what you need into your <script> block. These are intentionally vanilla JS
// (no imports) and self-contained.
//
// =============================================================================
// MCP response parsing
// =============================================================================
// Same tool returns different shapes in chat vs. widget runtime. The widget
// often returns content blocks like {content:[{type:"text",text:"..."}]}, and
// some Coupler tools (notably list-datasets) prepend a prose line:
//   "Total datasets: 1\n\n[ ... ]"
// So a naïve JSON.parse(content[0].text) fails. tryJsonFromText recovers by
// finding the first JSON token and parsing forward.

function tryJsonFromText(txt) {
  if (typeof txt !== "string") return null;
  try { return JSON.parse(txt); } catch (e) {}
  // Find the first '[' or '{' and try to parse from there
  const candidates = [];
  const a = txt.indexOf("[");
  const o = txt.indexOf("{");
  if (a !== -1) candidates.push(a);
  if (o !== -1) candidates.push(o);
  candidates.sort((x, y) => x - y);
  for (const start of candidates) {
    for (let end = txt.length; end > start; end--) {
      try { return JSON.parse(txt.slice(start, end)); } catch (e) {}
    }
  }
  return null;
}

function parseToolResult(res) {
  if (res == null) return null;
  if (typeof res === "string") return tryJsonFromText(res) ?? res;
  if (Array.isArray(res)) {
    if (res.length && res[0] && typeof res[0] === "object" &&
        (res[0].type === "text" || typeof res[0].text === "string")) {
      const txt = res.map(c => c.text || "").join("");
      return tryJsonFromText(txt) ?? txt;
    }
    return res;
  }
  if (typeof res === "object") {
    if (Array.isArray(res.content)) {
      const txt = res.content.map(c => (c && c.text) || "").join("");
      return tryJsonFromText(txt) ?? txt;
    }
    if (typeof res.text === "string") return tryJsonFromText(res.text) ?? res.text;
    if (res.result !== undefined) return parseToolResult(res.result);
    if (res.data !== undefined) return parseToolResult(res.data);
    return res;
  }
  return res;
}

// =============================================================================
// Coupler value handling
// =============================================================================
// Coupler stores string columns with embedded double quotes:
//   col_1 = '"Looker Studio"'  // includes the quote characters
// SQL filters must include the quotes; display layer must strip them.

function stripQuotes(v) {
  if (v == null) return "";
  const s = String(v);
  if (s.length >= 2 && s.startsWith('"') && s.endsWith('"')) return s.slice(1, -1);
  return s;
}

// Build a SQL equality predicate that matches BOTH Coupler quote conventions.
// The same dataflow has been observed storing strings as 'value' in one snapshot
// and '"value"' in the next. Matching both costs nothing and survives flips.
function couplerEq(colExpr, value) {
  const escaped = String(value).replace(/'/g, "''");
  return `${colExpr} IN ('${escaped}', '"${escaped}"')`;
}

// Inspect the convention from a sample row. Returns "quoted", "plain",
// or "mixed". Use this when you'd rather branch than match both forms.
function detectQuoteConvention(sampleStringValue) {
  if (typeof sampleStringValue !== "string" || sampleStringValue.length < 2) return "plain";
  return sampleStringValue.startsWith('"') && sampleStringValue.endsWith('"') ? "quoted" : "plain";
}

// =============================================================================
// Timezone-safe month strings
// =============================================================================
// new Date(y, m, 1).toISOString() is timezone-poisoned: for users east of UTC,
// local midnight on the 1st falls before UTC midnight on the previous day,
// so the ISO date is "previous-day-of-previous-month". This silently produces
// zero-row queries because the month string never matches data.
// Always build YYYY-MM-01 strings manually.

function monthFirst(date) {
  const y = date.getFullYear();
  const m = date.getMonth();
  return `${y}-${String(m + 1).padStart(2, "0")}-01`;
}

function prevMonthFirst(date) {
  let y = date.getFullYear();
  let m = date.getMonth() - 1;
  if (m < 0) { m = 11; y -= 1; }
  return `${y}-${String(m + 1).padStart(2, "0")}-01`;
}

function monthLabel(iso) {
  const [y, m] = iso.split("-");
  return new Date(+y, +m - 1, 1).toLocaleString("en-US", { month: "short", year: "numeric" });
}

// =============================================================================
// Snapshot lookup + run-and-poll refresh
// =============================================================================
// Always resolve last_dataset_snapshot_id at load via list-datasets — never
// hardcode it. For forced refresh (button), call run-dataflow and poll
// list-datasets until the snapshot ID changes.

// All Coupler.io operations go through the single dispatcher tool.
// Operations are invoked as {verb:"call", name:"<operation>", args:{...}}
// with snake_case args (dataflow_id, dataset_snapshot_id).
const COUPLER_TOOL = "mcp__b2221b32-5723-40e6-b17d-a36abcd4c057__coupler";

async function callCoupler(name, args) {
  return await window.cowork.callMcpTool(COUPLER_TOOL, { verb: "call", name, args });
}

function extractDatasets(parsed) {
  if (!parsed) return [];
  if (Array.isArray(parsed)) return parsed;
  if (Array.isArray(parsed.datasets)) return parsed.datasets;
  if (parsed.data && Array.isArray(parsed.data.datasets)) return parsed.data.datasets;
  if (parsed.result && Array.isArray(parsed.result.datasets)) return parsed.result.datasets;
  return [];
}

// Returns { id: snapshotId, runAt: ISO } or throws.
async function fetchSnapshotInfo(dataflowId) {
  const raw = await callCoupler("list-datasets", { dataflow_id: dataflowId });
  const ds = extractDatasets(parseToolResult(raw));
  if (!ds.length) {
    throw new Error("Dataflow not visible. Raw: " + JSON.stringify(raw).slice(0, 200));
  }
  return { id: ds[0].last_dataset_snapshot_id, runAt: ds[0].last_success_run_at };
}

// Run a SQL query against the given snapshot. Returns the row array.
async function runQuery(snapshotId, query) {
  if (!snapshotId) throw new Error("No snapshotId");
  const raw = await callCoupler("get-data", { dataset_snapshot_id: snapshotId, query });
  const parsed = parseToolResult(raw);
  if (Array.isArray(parsed)) return parsed;
  if (parsed && Array.isArray(parsed.rows)) return parsed.rows;
  if (parsed && Array.isArray(parsed.data)) return parsed.data;
  return [];
}

// Force a refresh: trigger run-dataflow, poll list-datasets until snapshot
// ID changes (or up to maxMs). Returns the new snapshot info or throws.
async function forceRefresh(dataflowId, oldSnapshotId, opts = {}) {
  const intervalMs = opts.intervalMs ?? 5000;
  const maxMs = opts.maxMs ?? 5 * 60 * 1000;
  await callCoupler("run-dataflow", { dataflow_id: dataflowId });
  const start = Date.now();
  while (Date.now() - start < maxMs) {
    await new Promise(r => setTimeout(r, intervalMs));
    try {
      const info = await fetchSnapshotInfo(dataflowId);
      if (info.id && info.id !== oldSnapshotId) return info;
    } catch (e) { /* keep polling */ }
  }
  throw new Error("Refresh timed out");
}

// =============================================================================
// Format helpers
// =============================================================================

function fmtNum(n) {
  if (n == null) return "—";
  const v = +n;
  if (!isFinite(v)) return "—";
  return v.toLocaleString("en-US");
}

function fmtAgo(iso) {
  if (!iso) return "unknown";
  const t = new Date(iso).getTime();
  if (!isFinite(t)) return iso;
  const diff = Date.now() - t;
  const m = Math.round(diff / 60000);
  if (m < 1) return "just now";
  if (m < 60) return m + "m ago";
  const h = Math.round(m / 60);
  if (h < 24) return h + "h ago";
  return Math.round(h / 24) + "d ago";
}

function pct(n, d) { return d ? (100 * n / d).toFixed(1) + "%" : "—"; }

function deltaPct(cur, prev) {
  if (prev == null || prev === 0) return null;
  return ((cur - prev) / prev) * 100;
}

// =============================================================================
// Chart.js sizing helper
// =============================================================================
// With responsive:true, maintainAspectRatio:false, the canvas's PARENT must
// have an explicit pixel height. Without it, Chart.js silently collapses
// the canvas. Wrap canvases in a div like:
//
//   <div style="position:relative;height:260px;width:100%">
//     <canvas id="myChart"></canvas>
//   </div>
//
// And pass animation:false on first render to avoid layout flicker.

// =============================================================================
// localStorage state
// =============================================================================

function loadState(key, defaults) {
  try {
    const stored = JSON.parse(localStorage.getItem(key)) || {};
    return Object.assign({}, defaults, stored);
  } catch (e) { return Object.assign({}, defaults); }
}

function saveState(key, state) {
  try { localStorage.setItem(key, JSON.stringify(state)); } catch (e) {}
}
