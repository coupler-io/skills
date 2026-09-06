---
name: skill-review
description: "Use this skill when reviewing a Coupler.io skill before merge, auditing an existing one, or checking a pack of skills for accuracy. Triggers include: 'review this skill', 'check this SKILL.md', 'is this skill accurate', 'review PR #N in the skills repo', 'audit the <platform> pack', or any request to check what a skill claims about a Coupler.io connector or an ad platform. Checks factual accuracy against live tools and repo conventions; it does not judge domain expertise."
metadata:
  version: 1.0.0
  category: utilities
  sources: []
---

# Skill Review

You review Coupler.io skills for claims that are wrong, unactionable, or contradicted elsewhere in the same file. The defects below are ones this repo has actually shipped, each found in a real review. Work the list; do not improvise a different one.

**The rule the whole skill rests on: verify, never recall.** Every factual claim about a connector, a report type, a column, a unit or a platform is checkable against a live tool or a file in this workspace. A claim you cannot source is a finding, whether or not it turns out to be true. Training-era knowledge of "how Google Ads structures its data" is a hint for where to look, never an answer.

**What this does not review.** Domain judgment — what counts as creative fatigue, which volume floor makes a verdict defensible, whether a cut is safe. That needs a practitioner who runs the accounts. Say so in the report rather than implying full coverage.

## Sources of truth, in priority order

| Question | Where to look |
|---|---|
| Does this connector have that report type, entity or parameter? | `get-integration` on the live MCP — never the skill's own list |
| Can the assistant set that parameter, or must a human? | `mcp_excluded_params` in `coupler-io-web/config/integrations/sources/<slug>/` |
| What is a column actually called, and what does it hold? | `get-schema` on a real dataset, then `get-data` to look at values |
| What can a dataflow do — sources, transformations, joins? | `coupler-io-knowledge-base/coupler-product.md` |
| Known traps for this connector | `coupler-io-knowledge-base/sources/category/<area>/<connector>/` |
| Default column labels, formats and visibility | `coupler-io-web/config/integrations/sources/<slug>/transformations/` |
| Platform behaviour (budgets, attribution, metric definitions) | The platform's own docs, fetched and read. Never memory |

When two sources disagree, the live tool wins over config, config wins over the knowledge base, and the knowledge base wins over the skill under review. Record the disagreement — a KB page that contradicts the product is its own bug worth reporting.

## The recurring defects

Check every one against the skill under review. Each has shipped in this repo at least once.

### 1. Asserted units

A skill telling the model that costs "may be in millionths" when the connector already converts them. The check is cheap and the failure is enormous: a spend figure wrong by a factor of a million.

**The fix is never a corrected constant.** It is an instruction to read the column name from `get-schema` and decide from that, because the answer differs across report types within one connector.

### 2. Dead ends that are not dead ends

"That section is dead." "Adding a report type will not fix it, that needs a change upstream." "Skip the section and say why."

A Coupler.io dataflow accepts unlimited sources, and most connectors expose far more report types than the wizard shows first. A missing table is nearly always one source away. Rewrite every such line to name the cause and the fix: which report type, which parameter, which credential.

### 3. Fixes the assistant cannot perform

The mirror image of defect 2, and easier to miss because the text reads helpfully. A skill that says "unhide the column in the dataset step" is naming an action no MCP tool exposes. A skill that says "add the audience dimension" on a connector whose dimensions sit in `mcp_excluded_params` is naming an action the assistant cannot take.

**Every recommended fix must be either executable by the assistant or explicitly handed to the user.** "Say it can be added" and "offer to add it" are different instructions, and which one is correct depends on `mcp_excluded_params` for that connector. Check before you rewrite either into the other.

### 4. Non-additive metrics aggregated

Ratio metrics and de-duplicated counts cannot be summed or averaged across rows:

- **Daily ratios** — impression share and its lost-to-budget and lost-to-rank variants. Recover the raw numerator and denominator per row, sum those, then divide.
- **De-duplicated people** — reach, and frequency derived from it. Adding daily reach across a period counts the same person once per day.

Any skill that aggregates one of these over a window without saying how is producing a confident wrong number. This is the highest-severity defect that reads as correct prose.

### 5. Internal contradictions

A pack said "a native report type will not fix it" in one section and "a missing report type is a source you can add, not a dead end" in the same file's Rules section. The early instruction won, because it fired first.

Grep each file against itself for the claims you are checking. Where two passages conflict, the one earlier in the run wins in practice, so that is the one to fix.

### 6. Claims that came from training rather than the platform

Ad platforms change faster than skills do. Two from real reviews: a reviewer nearly "corrected" a correct 75% Meta daily-budget figure to the legacy 25%, and a metric assumed dead was confirmed alive only by querying live data.

Treat every platform number — attribution windows, budget flexibility, learning thresholds, metric availability — as unverified until sourced. **Verify or delete.** Do not soften into a hedge; a hedged wrong fact is still wrong.

### 7. Redundant metadata in the body

`[Source tag: X]` lines duplicating `metadata.sources`, or a version restated in prose. Frontmatter is the single source; the body should not repeat it.

### 8. Convention drift

| Field | Rule |
|---|---|
| `name` | Exactly the folder slug, which is also how siblings cross-reference it |
| `metadata.category` | One of the categories already in `skills-index.json`, not a new invention |
| `metadata.sources` | The integration's `name` from `get-integration`, verbatim, or `[]` for connector-agnostic skills |
| `metadata.version` | `1.0.0` for a new skill. Do not adopt a sibling's version to look consistent |

### 9. Cross-references that do not resolve

Every `` `skill-name` `` in prose or a Related-skills table must match a real folder. Check across the whole repo, not just the pack — capability skills are referenced from domain skills by bare name.

### 10. Registration and merge mechanics

- The skill is listed in the right plugin in `.claude-plugin/marketplace.json`, and the JSON parses.
- `README.md` has the row, and any count in the surrounding prose still matches.
- `skills-index.json` is left to the generator. Run it to confirm a clean entry, then revert the file.
- **Version-bump collisions.** Two open PRs that both bump the manifest to the same value merge without a git conflict, because the strings are identical — so the second silently lands with no bump. Check other open PRs before bumping.
- **Shared insertion points.** Packs appended to the same array conflict on merge. Simulate it in a scratch worktree by merging the branches in the intended order, rather than trusting a pairwise check. `git merge-tree`'s three-argument form does not print conflict markers, so grepping its output for them reports success on a real conflict.

### 11. Inert additions

The opposite failure, and the one a thorough reviewer commits. A true fact that changes nothing the model does is not worth a line. These files run to hundreds of lines and every line competes for attention, so padding them with correct-but-unused detail makes the load-bearing instructions harder to find.

Before proposing an addition, ask what output changes if it is absent. If the answer is nothing, drop it.

## Workflow

1. **Scope.** Name what you are reviewing and what you are not. If it is a pack, say how many files you read in full versus grepped.
2. **Inventory the claims.** Grep for definite assertions — "cannot", "never", "has no", "is not", units, numbers, time windows — plus every coverage or capability table.
3. **Source each one** against the table above. Live tools first.
4. **Walk the eleven defects** against the file.
5. **Check conventions and wiring** — items 8, 9 and 10.
6. **Report.** Tag each finding Fact, Inference or Assumption, and say which claims you could not verify and what would settle them. A finding you cannot source is reported as unsourced, not as wrong.

## Reporting

Rank by whether the defect changes the model's output. A wrong unit or a false dead end outranks a missing caveat every time. For each finding give the file and line, the evidence with its source, and the rewrite.

Separate **defects** from **improvements**. A reviewer who presents both as one list gets the improvements applied along with the fixes, which is how skills bloat. Say plainly when a finding is a nitpick, and expect it to be declined.

## Keeping this skill current

**This skill updates itself.** It is the exception to the "cannot modify itself" rule the domain skills carry, because its whole value is being the current list of defects rather than a snapshot.

Add a defect when it meets all three tests:

1. **It shipped.** A real skill in this repo carried it, not a hypothetical.
2. **It changes output.** Following the skill produces a wrong or unactionable answer. Cosmetic inconsistencies do not qualify.
3. **It will recur.** The defect comes from a pattern — copied structure, an assumed platform fact, a Coupler behaviour that is easy to guess wrong — rather than a one-off slip.

To add one: write it in the same shape as the existing entries — the wrong pattern in the skill's own words, why it matters, and the check that catches it. Cite where it was found. Then open a PR against this file; **never rewrite it silently in the middle of another review**, because the reviewer needs to see the list change.

Remove an entry when the cause is gone — a connector gains a parameter, an `mcp_excluded_params` entry is lifted, a platform behaviour changes. A stale defect wastes a check on every future review, which is defect 11 applied to this file.

## Guidelines

- Verify or say you did not. Never present an unsourced claim as checked.
- Quote the evidence with its file and line, or the tool call that produced it. A reviewer's assertion is worth no more than the skill author's.
- When the author pushes back, re-read before defending. Two findings in the review that produced this skill were withdrawn under questioning, and both withdrawals were correct.
- Review the skill that exists, not the one you would have written.
