---
description: Rewrite text to remove AI patterns and add human voice
allowed-tools: Read, Write, Edit
argument-hint: [text or file-path]
---

Load the humanizer skill's pattern catalog from @${CLAUDE_PLUGIN_ROOT}/skills/humanizer/references/ai-patterns.md and the core instructions from @${CLAUDE_PLUGIN_ROOT}/skills/humanizer/SKILL.md.

If `$ARGUMENTS` is a file path, read the file. Otherwise treat `$ARGUMENTS` as the text to humanize.

Scan the text against all 23 patterns in the catalog. Rewrite every flagged section. Apply the voice principles from the skill (vary rhythm, have opinions where appropriate, use first person when it fits, be specific).

Preserve the original meaning, intended audience, and register. Do not inflate or deflate formality — match what's there.

Return the rewritten text. After the text, include a short summary grouping the changes by pattern category (content, language, style, communication, filler). Skip the summary if fewer than 3 changes were made.
