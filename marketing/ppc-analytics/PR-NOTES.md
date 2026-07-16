# PR notes — ppc-analytics (Phase 4 Part B, framework validation build)

Branch: `framework-build-phase1`. Authored against `_framework/SKILL.template.md` + `_framework/conventions.md` + `_framework/README.template.md`. Content source of truth: CPL-25712.

## T-B0a — authoring wall-clock (labeled datapoint, NOT validation)

- **Start:** 2026-07-07 19:21 -03 (context load: framework artifacts + live patterns + brief)
- **End:** 2026-07-07 19:27 -03 (SKILL.md + evals.json + README.md authored, linter PASS)
- **Elapsed:** ~6 minutes wall-clock for T-B0–T-B3, T-B5, T-B6 authoring (excludes T-B4 composition runs and T-B7 review, deferred).
- **Label (verbatim, per plan finding #5):** "best-case: author == template-author, single instance, NOT generalizable — does NOT validate the 'fast to author' Heart sub-value". Real validation is deferred to the meta-skill + a non-author run (Tabled). No downstream doc may cite this number as speed validation.

## Deferred — NOT done in this pass (do not read as passed)

- **T-B4 (AC-B.4)** — empirical composition runs (does the model reliably load `report-generation` + `create-dataflow`?): **DEFERRED to tomorrow.** No reliability observation exists yet; hardening decision pending measurement. Eval EXECUTION (T-B5 "run them") is deferred with it — evals are authored, not yet run.
- **T-B7 (AC-B.3)** — named senior-PPC-analyst blind review: **DEFERRED to tomorrow.** Reviewer name still `[SET — Aurelien to name]` per the plan's Open Dependencies. AC-B.3 cannot pass until then; no self-certification.
- **Acquisition checklist item (iv), flat surface:** linter PASS; **flat-for-`get-skill` surface PROVISIONAL pending the T-4 gate** (get-skill size cap / references bundling / `{{ }}`-escaping still open with Peter). Not fabricated as passed.
- **Track-A PR + site page (AC-B.6 full surfaces):** the Track-A block variant and site slug/title/GTM-label guidance are authored (README); the actual `marketingskills` PR and the coupler.io page publication are launch steps outside this authoring pass.

## Acquisition-readiness checklist (run 2026-07-07, per item)

- (i) SEO/human-discovery README per template, four elements, no brackets left — **PASS**
- (ii) Trigger-rich `description` per formula (what + triggers + boundary), 981/1024 chars — **PASS**
- (iii) Per-track block correct: Track-B variant in SKILL.md Step 0 (target track = Coupler repo); Track-A variant only in the clearly-marked README section, not in the skill — **PASS**
- (iv) Spec-conformant: `bin/validate-skills.sh marketing/ppc-analytics` → PASS. **Linter PASS; flat surface PROVISIONAL pending T-4 gate** — item INCOMPLETE until T-4 clears, per finding #1. — **FLAGGED**
- (v) GEO/SEO-ready: JTBD-query-shaped description, ICP-keyworded slug/title guidance, comparison/switch angle (README § Site page guidance) — **PASS**
- (vi) GTM attribution label proposed: `ppc-analytics-download-skill-hero` (page-action-block; page segment == skill name) — **PASS (proposed; wiring is a site-page step)**

## Framework-drift observations (T-B8 input — noted, NOT silently patched)

1. **README.template.md has no slot for checklist items (v) and (vi).** The acquisition-readiness checklist requires site slug/title guidance, a comparison/switch angle, and the GTM label, but the README template's four elements don't cover them — this skill adds an ad-hoc "Site page guidance" section. Part A should either add a fifth template element or state where (v)/(vi) evidence lives.
2. **Template section-title AC references leak into authored skills.** The template's step headings carry framework citations ("AC-1.2", "AC-1.7") that mean nothing to an end reader; dropped here (kept the structure + MANDATORY/REQUIRED markers). Part A may want reader-facing heading variants.
3. Minor: the template instructs "Delete the guidance comments before publishing" but the checklist has no item verifying no template comments/brackets remain in SKILL.md (only the README is bracket-checked in item (i)). Cheap linter or checklist addition.

## Open escalations carried

- Final path/name `marketing/ppc-analytics` — confirm with repo owner (per T-B0 note).
- Senior PPC analyst reviewer name — blocks T-B7/AC-B.3.
- T-4 gate (Peter): size cap, references bundling, double-brace escaping → unblocks flat surface + checklist (iv).

## Update — 2026-07-15 (framework finish + independent eval)

Supersedes the "Deferred" and checklist-(iv) items above where noted.

- **T-4 gate CLEARED (Peter, 2026-07-08):** no skill body-size limit; `get-skill` does not bundle `references/` (build-time inlining is the required path). PROVISIONAL embargo lifted; **checklist item (iv) now PASS** — flat surface no longer stubbed.
- **Eval EXECUTED (T-B4 / T-B5) — 2026-07-15, against live ad data in the Coupler *Templates* workspace** (multi-channel ROAS dataset carrying Facebook / Google / Instagram sources). Run through an **independent runner→grader pipeline — author ≠ runner ≠ grader** (no creator/validator bias): the runner had only the served skill + the user prompt + the live MCP; the grader had only the assertions + the transcript; graders re-ran every query to confirm no fabrication.
  - **Result: 4/4 evals pass · 19/19 assertions.** The attribution caveat fired correctly in evals 2 & 3 (refused to sum FB + Google conversions; gave per-platform + GA4/blended-CAC alternative). Efficiency-not-volume ranking held (declared Google the winner despite Meta's higher raw spend). Data-artifact caveats (partial period, conversion-lag restatement) were raised before behavioral causes. Zero fabricated numbers.
  - **One fix applied (a1-5):** eval 1 was initially partial — the skill didn't expand metric abbreviations on first use. Fixed in the **template** (Present step) + this skill; re-ran eval 1 → **PASS (5/5)**.
- **Composition reliability (AC-B.4):** observed across the 4 real runs — the skill consistently kept spend-summing separate from conversion-summing and applied the report structure; no composition flakiness surfaced. (Still an LLM-behavior observation, not a hard guarantee.)

### Still open
- **T-B7 / AC-B.3 — named senior-PPC-analyst blind review:** STILL PENDING. The independent LLM grader is a strong *behavioral* check, not the human *domain* sign-off. Outreach to Artem Sahaidak / Yulianna Dobosh is out for a specialist reviewer (and a real production ad workspace beyond the demo data).
