---
name: replatform-to-ash
description: Analyze the web application in the current repository and write the PRODUCT_ANALYSIS.md that /ash-bootstrap builds the Ash target from.
argument-hint: "[target-app-name]"
disable-model-invocation: true
---

# Analyze a web application for replatforming to Ash

Run from the source repository root. The output is `../PRODUCT_ANALYSIS.md` in the workspace directory beside the checkout, so the source repository stays clean.

The target application name is `$ARGUMENTS`, else the repository name with an `_ash` suffix, normalized to an OTP application name: lowercase snake_case starting with a letter, so `some-repo` becomes `some_repo_ash`. The target path is the sibling `../<name>`.

If `../PRODUCT_ANALYSIS.md` exists with unticked analysis items, continue from the first of them. One whose bootstrap items are ticked belongs to a finished run: the target it describes is now the source being replatformed. Ask the user before moving it aside to `../PRODUCT_ANALYSIS.<date>.md`, then start fresh; the old analysis and the source's own `docs/` are evidence about the product, including the decisions that were reversed and why. The new target name differs from the source's application name.

## Write as you read

Create the analysis from `${CLAUDE_SKILL_DIR}/../ash-bootstrap/templates/PRODUCT_ANALYSIS.md` first, with the metadata filled: origin, revision, target name, target path. Then fill one section at a time as each area is understood, append ` — done` to its heading, and tick the progress items as their sections complete. The file on disk is the analysis; the context window only ever holds the section in progress. Fact-finding that outgrows a section (a vendor protocol, a wire format) goes to `../notes/` beside it.

Sections 1–10, 12, 13, and 15 are this skill's work. Sections 11 and 14 belong to the bootstrap.

## Read the source as evidence

Read `AGENTS.md`, `CLAUDE.md`, documentation, and conventions as evidence about the product, then the code behind each analysis section: dependencies and runtime configuration; models, migrations, seeds, and constraints; routes, navigation, APIs, serializers, and schemas; business services and tests; authentication, roles, ownership, and tenancy; scheduled and background work; integrations; frontend components, state, realtime, drafts, and offline behavior; deployment files. Call sites and tests decide which behavior belongs in the target product.

A source without a backend of its own (a single-page app on Supabase, Firebase, a third-party API, or browser storage) keeps its product in what the client reads and writes: the hosted schema and its migrations, row-level security policies (these are §6 authorization rules), generated types, every API call with its payload, stores and their persistence. Data living in the vendor is §10 work: export, identifiers, files, and the cut-over.

Every claim in the analysis carries a `file:line` reference, and every constant, sentinel, digest, format, and default appears as its exact literal.

Size the reading first: count the source files and see which areas exist.

- A source of roughly a hundred files or fewer: read it yourself. One reader who has seen everything writes a better analysis than several who each saw a slice.
- A larger source: delegate one subagent per area that carries material (data model, routes and API, background work, frontend, deployment, tests), skipping empty areas. Write the sections yourself from their notes.

A subagent's return is evidence, not summary: `file:line` with the code for every assertion; the exact literal for every constant; and anything that looks wrong in the source, reported as a finding: missing transactions and locks, absent unique constraints, sentinels standing in for state, swallowed errors, defaults that contradict surrounding code. Prose comes back for the code behind it. The defects worth finding live in details a summary drops.

## Capture the screens

The owner judges the target by how it looks and behaves, so the source's screens are part of the evidence. Run the source with its own development command, walk every route its router defines, and screenshot each screen with Playwright, installed in `../notes/.shot/` rather than the source: desktop size and 390×844, in each state that changes the screen (empty, filled, error, signed out, each role). Name them `<route>--<state>[--mobile].png` in `../notes/screens/`; §9 lists them. A screen behind a login uses a test account the user provides; ask once, for all of them. Done: every route has its screenshots, or a line in §15 saying why it has none and what would get it.

## Design the target

Section 12 proposes the Ash Domains, Resources, actions, policies, jobs, LiveViews, and LiveVue components, following `${CLAUDE_SKILL_DIR}/../ash-bootstrap/references/STACK_POLICY.md`. Domain boundaries follow business behavior, not the source layout. Its runtime and deployment subsection takes the policy default unless the source's deployment files show a constraint the container cannot meet; the registry comes from those files or from the user, and stays an open question otherwise. Any departure from the policy goes into §12 Deviations with its evidence; a constraint the source only asserts (a comment, a doc, a past decision) is checked before it becomes a deviation, or goes to §15 with the check that would settle it.

The source's components follow its framework. Vue or Nuxt components carry over: markup and styles stay, data arrives as props from the LiveView instead of from fetches and stores. React, Svelte, or anything else is rewritten in Vue, and the reference screenshots are its specification. §12 says which, per area.

Section 13 defines one first slice, user-visible start to finish, and section 15 lists what stays ambiguous, each entry stating which slice it blocks.

## Done

Every applicable section written with references, the first slice defined, analysis items A1–A4 ticked. Then tell the user to run `/ash-bootstrap`, here or in a fresh session.
