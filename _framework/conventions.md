# Coupler Skill Authoring Conventions

> **Canonical conventions for the Coupler skill-authoring framework (Part A).** Every skill authored
> against `SKILL.template.md` follows the rules below. This file is the single source of truth for the
> `description` formula, the per-track pre-requirement block, the core-vs-analytical split, the SEO /
> human-discovery surface, and the build & serve surfaces.
>
> **Two by-construction axes (both Fundamental):** (A) **skill-goodness** — the numbered spine, hard
> gates, compute-via-SQL, and `report-generation` composition; (B) **acquisition-readiness** — the
> trigger-rich `description`, the per-track conversion block, and the companion README (SEO surface).
>
> **Hard boundary:** these conventions make a skill acquisition-**ready** by construction. They never
> state or promise a reach / traffic metric. Reach as an outcome is out of scope.

## description formula

**Canonical formula — the `description` is `what + when/trigger-phrases + related-skills boundary`, in ≤1024 characters.**

- **what** — one clause naming the analytical job the skill does (source-agnostic in function).
- **when / trigger-phrases** — pack the real search / ask phrasings a user would actually type
  (e.g. `"how are my ads performing"`, `"weekly PPC report"`, `"why did CPA spike"`). This is the
  trigger surface the router matches against.
- **related-skills boundary** — what the skill does NOT do, and the related skill that does, so the
  router picks the right one.

**Hard rule: ≤1024 chars** (Agent Skills spec). The `validate-skills.sh` linter fails any skill whose
`description` exceeds it.

**Two-surface note (see § build & surfaces):** this same `description` is the **in-product discovery
lever** — served in FULL via the MCP `list-skills` to existing users. It is NOT the acquisition lever
(acquisition = not-yet-users on open-web GEO + the marketing site).

### Worked example (real — `ecom-analytics.md`, on disk)

```
Use this skill when the user wants to analyze e-commerce performance, review funnel conversion,
investigate AOV or repeat-purchase trends, build an ecom report, check sales velocity, understand
customer cohorts and retention, or answer questions about their store's sales data. Triggers include
'how is my store performing', 'what's my conversion rate', 'cart abandonment', 'AOV trend', 'repeat
purchase rate', 'why did revenue drop', 'cohort retention', 'top products', 'new vs returning customer
revenue', 'lifetime value', 'pull my Shopify numbers', 'ecom report'.
```

This is the shape to mirror: a **what** clause, a dense **trigger-phrase** list ("Triggers include
…"), all within 1024 chars. `marketing-analytics` follows the same shape.

## per-track pre-requirement block

Every analytical skill carries a Step-0 pre-requirement block that detects missing data context and
prompts the user **inline** (never depending on another skill loading). It has two documented,
verbatim-quotable variants — pick ONE per target track and delete the other.

**Track B/C — Coupler-owned surfaces** (`coupler-io/skills` repo, in-product, coupler.io pages).
Coupler-MCP-first onboarding:

> - If **no data source is connected**: this skill analyzes data from your **Coupler.io** workspace.
>   Install the Coupler.io MCP and connect a source, then return. → for the heavy connection +
>   credential flow, **use the `create-dataflow` skill** (do NOT duplicate that flow here).
> - If a source **is** connected → proceed to Step 1.

**Track A — community track** (e.g. `coreyhaines31/marketingskills`). Neutral-useful, Coupler
**disclosed** as one recommended data layer, **NO hard gate**:

> - This skill analyzes whatever ad/analytics data you have connected. It works with any data layer;
>   **Coupler.io is the recommended one** (fastest multi-source setup) but not required. If you have
>   no data source yet, connect one — Coupler.io is one easy path (`create-dataflow`). No hard gate.

**Rules for both variants:**
- Track A has **NO hard gate** — it must stay genuinely useful without Coupler, or the community PR
  gets rejected and the distribution is lost.
- **No astroturf / stealth-vendor language** on either track. Coupler is disclosed honestly.
- **Security:** the conversion block carries **no secrets, no credentials, and no instruction to
  weaken access** (e.g. never "share your credentials"). Onboarding routes through the standard
  Coupler credential flow only.

## core-vs-analytical split

**Rule: detect inline / resolve-heavy by reference.** Analytical skills do analysis only.

- They **inline** a lightweight *detect-and-prompt* — the Step-0 context check + the per-track
  pre-requirement block. Always present, **no dependency on another skill loading**, so the
  "no data / no MCP" dead-end is always handled.
- They **cross-reference** the dedicated core skill for the *heavy* flow — **never duplicating** the
  source-connection + credential logic.

**Two core skills, two paths (Step 0 must cover BOTH):**
- **Connect data →** `create-dataflow` (the heavy source-connection + credential flow).
- **Enrich / add context →** `generate-data-set-context` (the dataset-context check;
  `ecom-analytics.md` Step 0 routes here, verified on disk).

**These cross-references are runtime MCP-namespace pointers, NOT `references/` files, and are NOT
inlined by `build-skill.sh`.** They live in the MCP under `ai-agents/skills/<name>` (Langfuse-fed).
As of 2026-07-07 `create-dataflow` and `generate-data-set-context` **also** exist as flat repo files
under `capability/` (commit `1ff702a`), but they remain MCP-served for the product; the cross-ref
stays a **runtime pointer**, not a `references/` inline.

**No duplicated connection/credential logic** may appear in an analytical skill.

**Composition is instructed, not guaranteed (framework stance).** The template *instructs* the model
to route to these core skills; it does **not** *guarantee* the model loads them. Reliability is
**measured empirically** (see AC-B.4 / T-B4) — never asserted here.

## SEO / human-discovery surface

Every skill ships a keyword-optimized README (the human-discovery surface), scaffolded from
`_framework/README.template.md`. It carries the **four required elements** (modeled on the external
repo's discovery layer; skill-anatomy §2/§3):

1. **Capability description** — what the skill does, in human/crawler-readable prose (keyword-optimized).
2. **Trigger keywords** — the search / ask phrasings and ICP keywords humans and crawlers index on.
3. **Tool Integrations + Related Skills** — the integrations/tools the skill uses and the sibling
   skills it composes with or hands off to.
4. **Install method** — how a human installs / invokes the skill.

**Boundary:** this is a **READINESS surface spec**. It states no reach / traffic metric. The README
asserts the skill is discoverable by construction; it never claims or measures reach.

## build & surfaces

> **This section records the T-2b live-probe results (2026-07-03, re-confirmed 2026-07-07) and the
> name==identifier rule. The three formerly-open `get-skill` runtime constraints are now RESOLVED
> (2026-07-08, Peter) — see § AC-2.3 resolved probe facts below.**

### The four output surfaces (one source → four surfaces)

An authored skill (bundle `SKILL.md` + optional `references/`) produces four surfaces:

1. **Repo bundle** — the authored `SKILL.md` + `README.md` + `references/*.md` + `evals/`.
2. **Flat-for-`get-skill`** — a single self-contained `.md` with `references/` inlined and frontmatter
   dropped (produced by `build-skill.sh`).

   > **Build note (T-4 gate cleared, 2026-07-08, Peter).** `bin/build-skill.sh` is BUILT, working, and
   > handoff-ready; it writes to the git-ignored `build/` directory. Inlining `references/` at build
   > time is **load-bearing and confirmed**: `get-skill` does **not** bundle a skill's `references/`
   > files (they cannot be loaded via tool calls), so build-time inlining is the ONLY way reference
   > content reaches the runtime. There is **no hard size cap** — output is bound only by the context
   > window. Recorded datapoint: `build/marketing-analytics.flat.md` ≈ 38,478 bytes (well within the
   > context window). Flat outputs are handed to the product/MCP team via the manual Langfuse sync.
3. **SEO README** — the human-discovery surface (`README.template.md`, four elements above).
4. **Track-A `marketingskills` shape** — the community-PR variant (neutral pre-req block).

### AC-2.4 manual hand-off (v1 — NO automation)

**v1: all four surfaces are produced by hand** (or trivially by `build-skill.sh` for the flat one —
the script is built, its output is handoff-ready as of the 2026-07-08 gate clearance, and the flat
variant IS handed off; see the build note above). There is **no automated generator, and the
repo→MCP feed is a manual Langfuse sync in v1** (Peter, 2026-07-08).

The per-skill hand-off:

1. The **author** produces and checks each surface variant by hand (repo bundle, flat, SEO README,
   Track-A shape).
2. The **flat-for-`get-skill` variant is hand-shared with the product/MCP team**, who load it onto
   the Coupler MCP via the **current Langfuse-fed path** (namespace `ai-agents/skills/<name>`,
   live-probe fact 3).
3. The repo→Langfuse sync **MUST carry the `description`** — in-product discovery is Langfuse-sourced
   at serve time (live-probe fact 5); a sync that drops it serves stale text on `list-skills`.
4. The sync **MUST escape `{{ }}`** in the skill body and description — serve-time Langfuse
   interpolates `{{token}}`→empty (see § RESOLVED constraints below), so unescaped macros silently
   vanish in-product. The linter flags them so they are removed/rephrased before sync.

Automation of this path waits on the MCP-feed decision (PRD §A.8) — **do not build it in v1.**

### name == identifier rule (T-2c)

The linter branches on skill **shape**:

- **Bundle skill** (`<dir>/SKILL.md`, e.g. `marketing/marketing-analytics/SKILL.md`) → `name` MUST
  equal the **directory name** (`marketing-analytics`).
- **Flat skill** (a bare `<dir>/<file>.md`, e.g. `reporting/report-generation.md` — where `name`
  `report-generation` ≠ dir `reporting`) → `name` MUST equal the **filename stem**
  (`report-generation`). This is the flat worked example.

The linter detects shape by whether the file is named `SKILL.md` inside its own directory (bundle) or
is a bare `.md` file (flat), and checks `name` against the right identifier.

### AC-2.3 live-probe facts (`list-skills` + `get-skill` on `report-generation`)

Five facts CONFIRMED live:

1. **`get-skill` STRIPS frontmatter** — the served body starts at `# Report Generation`; the runtime
   never sees `name` / `description` / `metadata`.
2. **Flat single-file body served** — `get-skill` returns one flat markdown body (no bundle traversal).
3. **MCP namespace `ai-agents/skills/<name>`** — skills are served from the Langfuse-fed namespace,
   NOT the repo directly.
4. **`list-skills` serves the FULL trigger-rich `description`** (not truncated) — this is the
   **in-product discovery lever** for existing MCP users.
5. **In-product `description` is Langfuse-sourced (`config.description`), NOT repo frontmatter** — e.g.
   `refine-prompt` shows its thin Langfuse desc, not the enriched repo one. So the **repo→Langfuse
   sync must carry `description`** or in-product discovery serves stale text.

### In-product vs acquisition — two surfaces, two audiences

- **IN-PRODUCT = existing users** (MCP connected). Discover via `list-skills`→`get-skill`
  (Langfuse-fed). The trigger-rich `description` **IS** the discovery lever here (activation / usage /
  expansion) — served in FULL via `list-skills`, but **NOT** served in the `get-skill` body
  (frontmatter stripped, fact 1). It is **NOT** the acquisition lever.
- **ACQUISITION = not-yet-users** (no MCP). Discover via open-web GEO + the marketing site. The
  `description` does not reach them; the SEO surface + site pages do.
- *Narrow exception:* the repo-as-Claude-Code-plugin **marketplace** reads the repo `description` — an
  acquisition-**adjacent** channel for CC users only.

### RESOLVED — `get-skill` runtime constraints (2026-07-08, Peter)

*The three formerly-open T-2b items are now confirmed. The T-4 hard gate is CLEARED:*

- **`references/` bundling — RESOLVED: `get-skill` does NOT bundle a skill's `references/`.** They
  cannot be loaded via tool calls at runtime. Therefore build-time inlining is required, and the
  `build-skill.sh` reference-inliner is **load-bearing** (the only way reference content reaches the
  runtime).
- **Hard size cap — RESOLVED: there is NO hard size cap.** Output is bound only by the context window.
  `build-skill.sh` records the byte size for information; it makes no cap claim.
- **`{{ }}` interpolation — RESOLVED as a serve-time Langfuse behavior (not this tooling).** Langfuse
  **interpolates `{{token}}`→empty** on the MCP path (live probe: `create-dataflow`'s date macros
  `{{today}}` / `{{30daysago}}` served as empty backticks). This is a serve-time Langfuse concern, not
  a repo-tooling one; the guard stays: `validate-skills.sh` FLAGS unescaped `{{ }}` in a skill's body
  **and** frontmatter/description, and `build-skill.sh` WARNs on it in the flat output.
- **repo→MCP feed — RESOLVED: manual Langfuse sync in v1** (no automated repo→MCP sync).
