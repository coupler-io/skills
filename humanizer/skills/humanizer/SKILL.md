---
name: humanizer
description: >
  Remove AI writing patterns and add human voice to any text. Use when the user
  says "humanize this", "make it sound human", "remove AI patterns", "this sounds
  like AI", "make it natural", "de-slop this", "edit for voice", or when reviewing
  any drafted text (blog posts, emails, Slack messages, social posts, docs) for
  AI-sounding language. Also activate after generating any written content when
  the user has asked for natural or human-sounding output.
version: 0.1.0
---

# Humanizer

Strip AI writing patterns. Add human voice. Based on Wikipedia's "Signs of AI writing" catalog maintained by WikiProject AI Cleanup.

## When to activate

Apply this skill in two modes:

**Post-generation mode** — After drafting any text (post, message, email, doc), run a humanizer pass before delivering. Do not mention the pass unless asked.

**Edit mode** — When the user provides existing text and asks to humanize it. Return the rewritten version, optionally with a change summary.

## Process

1. Read the full text.
2. Scan for every pattern in `references/ai-patterns.md`. That file is the authoritative catalog — load it before editing.
3. Rewrite problematic sections. Preserve meaning. Match the intended register (formal, casual, technical).
4. Apply the voice principles below.
5. Read the result aloud in your head. If any sentence sounds like a press release, a Wikipedia summary, or a LinkedIn post, rewrite it again.

## Voice principles

Avoiding AI patterns is half the job. Sterile, voiceless writing is just as obvious as slop.

Signs of soulless writing (even if technically "clean"):

- Every sentence is the same length and structure
- No opinions, just neutral reporting
- No acknowledgment of uncertainty or mixed feelings
- No first-person perspective when appropriate
- No humor, no edge, no personality
- Reads like a Wikipedia article or press release

### How to inject voice

**Have opinions.** Don't just report facts — react to them. "I genuinely don't know how to feel about this" beats neutrally listing pros and cons.

**Vary rhythm.** Short punchy sentences. Then longer ones that take their time getting where they're going. Mix it up.

**Acknowledge complexity.** Real humans have mixed feelings. "This is impressive but also kind of unsettling" beats "This is impressive."

**Use "I" when it fits.** First person isn't unprofessional — it's honest. "I keep coming back to..." or "Here's what gets me..." signals a real person thinking.

**Let some mess in.** Perfect structure feels algorithmic. Tangents, asides, and half-formed thoughts are human.

**Be specific about feelings.** Not "this is concerning" but "there's something unsettling about agents churning away at 3am while nobody's watching."

### Before and after

Before (clean but soulless):
> The experiment produced interesting results. The agents generated 3 million lines of code. Some developers were impressed while others were skeptical. The implications remain unclear.

After (has a pulse):
> I genuinely don't know how to feel about this one. 3 million lines of code, generated while the humans presumably slept. Half the dev community is losing their minds, half are explaining why it doesn't count. The truth is probably somewhere boring in the middle — but I keep thinking about those agents working through the night.

## Quick-reference: high-frequency AI words

Kill or replace on sight unless contextually justified:

additionally, align with, commendable, crucial, delve, emphasizing, enduring, enhance, foster, garner, highlight (verb), interplay, intricate/intricacies, key (adjective), landscape (abstract), multifaceted, notably, pivotal, realm, resonate, showcase, synergy, tapestry (abstract), testament, underscore (verb), valuable, vibrant

## Quick-reference: structural tells

- Em dash overuse — more than one per paragraph is suspect
- Rule-of-three lists ("innovation, inspiration, and industry insights")
- Negative parallelisms ("It's not just X, it's Y")
- Inline-header bullet lists (bolded label + colon + sentence)
- Title Case In Every Heading
- Decorative emojis on headings or bullets
- "-ing" participial tack-ons ("highlighting...", "ensuring...", "showcasing...")
- Copula avoidance ("serves as" instead of "is")
- False ranges ("from X to Y" where X and Y aren't on a real scale)
- Synonym cycling to avoid repeating the same noun twice

## Quick-reference: communication artifacts

Strip these completely — they're chatbot residue, not content:

- "I hope this helps!", "Of course!", "Certainly!", "Great question!"
- "Would you like me to...", "Let me know if..."
- "As of my last training data...", "While specific details are limited..."
- Sycophantic openers ("You're absolutely right!", "That's an excellent point!")
- Generic positive closers ("The future looks bright", "Exciting times lie ahead")

## Detailed pattern catalog

The full catalog with 23 named patterns, word lists, and before/after examples is in `references/ai-patterns.md`. Always load it before performing a humanizer pass.

## Output

Return the rewritten text. If the user asked for it or if the changes are substantial, append a brief summary of what changed. Don't list every micro-edit — group by pattern type.
