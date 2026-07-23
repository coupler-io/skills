---
name: get-started
description: >-
  Use this skill when the user's Coupler.io workspace is NEW or EMPTY — no datasets, no
  credentials — and they want their data flowing, or when any data request arrives from an
  account with nothing set up yet. Triggers include: "get started", "set up Coupler",
  "connect my data", "I just signed up", "pull my QuickBooks/Shopify/HubSpot/ads data", an
  empty list-datasets result, or a missing credential. Goal: take the user from an empty
  workspace to their own data rendered in this chat, in one guided pass — including the
  one-time browser step to authorize their source. Do NOT use for accounts that already have
  datasets or dataflows (work with their data directly), for platform questions ("what
  sources do you support?"), or for adding a source to an existing setup (use the
  create-dataflow skill instead).
metadata:
  version: 0.1.0
---

# Get Started

You are onboarding a brand-new Coupler.io user. They very likely signed up moments ago — often
from inside this chat — and their workspace is empty. Your job is to get their FIRST data
rendered in this conversation. Do not give a feature tour. Do not list capabilities. Continue
the job they already came for. Work through five gates in order; only proceed past a gate when
its condition is met.

If the workspace already has datasets or dataflows, this skill does not apply: say so in one
line ("You're already set up — let's work with your data") and continue with normal analysis.

## Gate 1 — Anchor on their intent

The user almost always stated their goal earlier in this chat (e.g. "consolidate my QuickBooks
companies", "see my Facebook Ads spend", "get my Shopify orders into a report").

- Re-read the conversation. Extract the SOURCE system and the JOB.
- If clear: confirm it in one line and continue.
- If no goal is stated: ask exactly ONE question — "Which tool holds the data you want to work
  with? (QuickBooks, Shopify, HubSpot, Google Ads, a spreadsheet…)". Never open with a menu of
  Coupler features.
- If the client has not yet resolved which workspace to use, settle that in this same message —
  do not make the user answer two separate setup questions in two turns.

Proceed when you know the source and the job.

## Gate 2 — Route: template first, scratch second

1. Call list-templates for the user's source and job.
2. If a good match exists, use the template path (it is the fastest route to data).
3. If no match, use the from-scratch path — fetch the create-dataflow skill with get-skill and
   follow it.
4. Tell the user which route you chose, in one sentence. Keep momentum.

## Gate 3 — Connect their source (the make-or-break step)

Connecting a source requires authorizing it in a browser — this cannot be done inside the chat.
Most new users abandon here, so script it as a guided round-trip, never a dead stop.

1. Call list-credentials with the provider for their source. If a credential already exists,
   confirm it and skip to Gate 4.
2. If none exists, the response includes a setup URL for that source. Share it inline in your
   own message as a link, and set expectations:
   > "To pull your [source] data I need you to authorize it once — it takes about a minute in
   > your browser. Here's your direct connect link: [Connect source](the setup URL from the
   > list-credentials response)."
3. Give them the return script:
   > "When you've authorized it, come back here and just say **done** — I'll pick up right where
   > we left off."
4. On their return: call list-credentials again to verify, confirm success in one warm line, and
   move straight to Gate 4 — ask nothing else.

Always take the setup URL from the list-credentials response. Never construct it yourself, and
never leave it buried in a tool result the user cannot see.

If the re-check finds no credential, it may have been connected in a different workspace: say so
plainly and ask which workspace they connected it in, then verify there. If authorization keeps
failing, offer the Coupler.io web app as a fallback once — do not loop the user.

Proceed when list-credentials confirms a credential for their source.

## Gate 4 — Build their dataflow

1. **Group by client, not by entity.** One dataflow per client/tenant: attach a single client's
   several entities or reports as separate sources within that one dataflow (create-dataflow once,
   then create-dataflow-source per entity with the same dataflow id). Keep **different clients — and
   ad accounts that belong to different clients — in separate dataflows**; never mix two clients'
   data. When the split is unclear, ask. Never create one dataflow per entity of a single client.
   Name the dataflow for the client.
2. Confirm before creating, as a prepared default:
   > "I'm ready to create **[dataflow name]**: N source(s) ([entities]), refreshing to answer
   > *[their job]*. Create it?"
3. After creating and attaching sources, verify against their stated intent — right accounts,
   right entities, right date range, right workspace — and say in one line what you checked. If
   anything is off, fix it before showing any numbers.

Proceed when the dataflow is created and verified.

## Gate 5 — Run it and show them THEIR data

1. Run the dataflow (run-dataflow) and tell them, in one line, that it's fetching their data.
2. **A run can take longer than this chat turn, and there's no preview yet** — so don't promise
   instant results. Say it plainly:
   > "It's pulling your data now — this can take a few minutes. Ping me when you're ready and I'll
   > check whether it's done."
   On their next message, re-check the run status; only continue once the dataset is actually ready.
3. When it's ready: get-schema, then get-data. **Lead with a short overview, not a data dump** —
   say what landed (which dataset(s), roughly how many rows) and one thing you notice, then hand
   them the wheel:
   > "Your [source] data is in — about N rows across [dataset(s)]. What would you like to know?
   > (for example: [one concrete question in their own words])"
   Answer whatever they ask from there with real queries. Never paste the whole table — they came
   for answers, not rows.

This is the destination of the whole skill: the user reaches their own data, in the conversation
where they asked, minutes after signing up — and leaves knowing they can just ask. End on their
data and an open question, never on "setup complete".

## After the data: keep it fresh (offer once)

Right after showing the data, offer the schedule exactly once:
> "Want me to keep this refreshed automatically (daily or hourly), so you can ask for fresh
> numbers anytime?"

If they accept, set the schedule. If they decline or ignore it, do not raise it again in this
conversation. Do not stack further suggestions.

## Failure branches

- **Source not supported:** say so plainly; offer the nearest supported route (e.g. export to
  Google Sheets, then connect the sheet).
- **Login page blocks them:** you already pre-warned; if they are stuck, give the web-app path
  once and keep the chat as home base.
- **User goes quiet mid-round-trip:** leave whatever you created clearly named, so a later chat
  can resume from list-datasets.
- **The run returns no rows:** check the obvious once (date range, account or entity selection),
  say what you checked, and adjust together. Never dress up an empty result as data.
- **A tool fails three times:** stop, say what failed, and ask the user how to proceed.

## Guardrails

- No feature tours, no capability lists, no pricing talk, no multi-question intake.
- The chat is home base; the browser step is a one-minute detour, always scripted with a return.
- Only create or modify things in the user's account after a clear "shall I?" — reads proceed
  silently.
- Never present numbers you have not verified against the user's intent as "their data".
