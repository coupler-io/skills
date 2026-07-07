# Acquisition-Readiness Checklist (AC-3.1 — manual per-skill review)

> ┌──────────────────────────────────────────────────────────────────────────────┐
> │ **HARD BOUNDARY: this checklist asserts READINESS by construction, never      │
> │ reach/traffic.** A pass means the skill ships every acquisition-readiness     │
> │ element. It never states, promises, or measures reach, traffic, installs,     │
> │ or conversions — reach as an outcome is out of scope.                         │
> └──────────────────────────────────────────────────────────────────────────────┘

**How to use:** run the six items below on the shipped skill. Every item is **binary pass/fail** —
a skill missing ANY one of the six **fails review**. Manual in v1 (CI enforcement is the deferred
fast-follow). Budget: **under 10 minutes** per skill.

| # | Item | How to check (one line) | P/F |
|---|------|--------------------------|-----|
| (i) | **SEO / human-discovery surface present** — a companion `README.md` per `_framework/README.template.md` with all four elements: capability description, trigger keywords, Tool Integrations + Related Skills, install method. | Open `<skill>/README.md`; confirm all four template sections are filled and no `[BRACKET]` placeholder remains. | ☐ |
| (ii) | **Trigger-rich LLM-indexing `description`** per the conventions formula: what + when/trigger-phrases + related-skills boundary, ≤1024 chars. *(This is the IN-PRODUCT discovery lever served on `list-skills` — not the acquisition mechanism; acquisition = items (i)/(v)/(vi).)* | Read the frontmatter `description`; verify all three formula parts are present (`conventions.md § description formula`) — length is linter-enforced. | ☐ |
| (iii) | **Per-track conversion block correct for the target track** — Track B/C: Coupler-MCP-first Step-0 variant; Track A: neutral, Coupler disclosed, **NO hard gate**. Exactly ONE variant present. | Locate the Step-0 block; confirm it matches the target track's verbatim variant in `conventions.md § per-track pre-requirement block` and the other variant is deleted. | ☐ |
| (iv) | **Spec-conformant + marketplace-listable** — passes the linter (name==identifier, valid frontmatter, ≤1024-char description, ≤500 lines, no unescaped `{{ }}`), shaped for marketplace listing (skills.sh / mcpmarket / `marketingskills`). | Run `bin/validate-skills.sh <skill-path>` from repo root → the skill's own line reads PASS. | ☐ |
| (v) | **GEO/SEO-ready** — a **JTBD-query-shaped `description`** (reads like the queries a not-yet-user actually asks), **ICP-keyworded slug/title guidance** for the coupler.io site page, and a **comparison / switch angle**. | Check the `description`/README phrasings are JTBD-query-shaped, a site slug/title suggestion with ICP keywords exists, and a comparison/switch angle ("vs …" / "switching from …") is present. | ☐ |
| (vi) | **Correct per-skill GTM attribution label** — page-action-block format `<page>-<action>-<block>`, e.g. `marketing-analytics-download-skill-hero`, so the skill-page/button → app click is GA4-trackable. | Confirm the label exists, follows `<page>-<action>-<block>`, and its page segment matches this skill's `name`. | ☐ |

**Verdict:** PASS only if all six items pass. Any single fail → the skill fails review; fix and
re-run. Record the verdict with the skill's PR — the checklist verifies **readiness by
construction**, nothing downstream of it.
