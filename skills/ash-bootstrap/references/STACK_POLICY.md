# The Phoenix + Ash + LiveVue stack

The target stack shared by every project the bootstrap creates.

## Foundation

Elixir and OTP, Phoenix, Ash, PostgreSQL through AshPostgres, Phoenix LiveView,
LiveVue, UsageRules.

## Database

PostgreSQL. AshPostgres is the data layer Ash's extensions are built against, and
the Ash data layers published on Hex are PostgreSQL and SQLite. A source on
another server (MySQL, SQL Server) moves its data to PostgreSQL in analysis §10.
Where the organisation runs that other server and has no PostgreSQL yet, getting
one is a question for whoever runs its databases: §12 records the server the
target needs, §15 the question, and the slices that touch data wait for it.

## Web architecture

The entire application UI is built with LiveVue components hosted by LiveView.

- LiveView owns routing, sessions, authoritative server state, subscriptions, and server-driven updates.
- Vue is the component and rendering layer for every screen: forms, CRUD, navigation, filters, dashboards, complex interactions.
- Persisted product state flows through Ash actions.
- Local component state stays in Vue and synchronizes with LiveView through explicit props and events.

A product whose client cannot run this layer (a device whose browser is too old
for the component layer's CSS, for example) replaces it in analysis §12
Deviations, with the evidence that the client cannot run it. This is a rare
exception: the default holds for every product that does not prove otherwise.

## Component layer

shadcn-vue with Tailwind. It is a CLI that copies component source into the
project rather than a dependency, built on Reka UI, which arrives as its runtime
dependency.

Installed by the bootstrap: `reka-ui`, `class-variance-authority`, `clsx`,
`tailwind-merge`, `tw-animate-css`, `@lucide/vue` for icons, `@vueuse/core` for
composables. Added by the first screen that needs them: `motion-v` for
animation, `echarts` with `vue-echarts` for charts.

- Add components one at a time through the shadcn-vue CLI. The copied source is
  project code, edited in place rather than wrapped. It receives no upstream
  updates; fixes are ported by hand.
- `components/ui` holds the generated primitives; a `vue` directory holds pages
  and product components.
- shadcn-vue is a base, not a ceiling. Reach for Reka UI directly when a behavior
  has no generated primitive, and write product components freely.
- One component library. Phoenix-side component packages target LiveView
  templates and overlap with this layer.
- Portal-based components (dialog, sheet, popover, tooltip) render outside the
  component root. This works with LiveView, and it is the first place to look
  when the DOM and LiveView disagree.
- SSR is a per-project decision. Whatever is chosen, verify the component layer
  under that setting, not only in development. Since live_vue 1.2.3 production
  SSR runs inside the VM (`LiveVue.SSR.QuickBEAM`): the runner image needs no
  Node, and an analysis must not plan one for SSR.

## Forms

`AshPhoenix.Form` on the server, `useLiveForm` from LiveVue on the client. That
pairing already carries values, server errors, nested objects, field arrays, and
validate/submit/reset.

Fields are written out explicitly. shadcn-vue's AutoForm exists only in the
pre-Tailwind-4 line and targets zod v3; generating field schemas from Ash was
evaluated and rejected (`ASH_FEATURES.md`, `ash_typescript`). Revisit only with a
project whose screens are mostly forms, and measure on the third one before
building anything.

## Application architecture

- Cohesive Ash Domains model business capabilities; boundaries follow business
  behavior, not the source repository layout.
- Product behavior lives in Resources, actions, policies, calculations,
  validations, and changes.
- Deterministic business rules stay in deterministic Elixir code.
- AshOban carries durable or scheduled work.
- An API that a client outside the repository calls (a mobile app, another
  service, a webhook sender) is a contract and is preserved. The source's own
  frontend-to-backend API is not: LiveView replaces it, and what the user sees
  and does is the contract.
- Domain boundaries are declared in code and checked (Quality harness,
  "Architecture checks").
- Every optional dependency is justified by a concrete behavior in the analysis;
  `ASH_FEATURES.md` is the catalog and the selection rules.

## Admin screens

Admin screens are product screens, built as slices on one shell. `ash_admin`
generates a raw table per resource: an operator's view behind the superadmin
check at most, since it carries no workflow, no per-section rights and no record
of who changed what. The shell:

- **Permissions catalogue**: one module lists the admin sections in display
  order, each with its label. A user holds a section at `read` or `write`.
- **Access roles**: a role grants sections at levels, users hold roles (or the
  product's existing groups map onto them), and a superadmin list in a runtime
  variable holds every section.
- **Policy check**: `authorize_if {Can, permission: :section, level: :read}` in
  each admin resource's policies. It reads the actor's levels on every check, so
  revoked access stops writes from a tab that is still open.
- **Section bar**: one Vue component lists the screens the user may open, built
  from the catalogue, on every admin page.
- **Journal**: each admin write is recorded with the actor, the section and the
  change (`ash_paper_trail`, or a resource of the product's own), and a journal
  screen reads it.

The shell is a slice of its own in analysis §13, ahead of the first admin screen.

## Quality harness

The owner of a project on this stack watches tests and behavior, not code. The
harness makes that enough: every class of mistake an agent makes turns the
**gate** red, and the agent fixes it before anyone sees it.

A rule reaches the code through four levers, strongest first: a **check** that
turns the gate red; a framework declaration that leaves one way to write the
thing (an Ash action, a policy, a typed prop); the neighbour code the agent
copies; a line of text in `CLAUDE.md`. Text alone holds a rule in part: on one
project with a written rule for each, 38 timers bypassed the named scheduler,
`Repo` was called from 78 files, and 50 files passed 1000 lines. So each rule the
product depends on gets the strongest lever that can hold it, and a rule a
script can detect becomes a check.

- **One gate.** `mix precommit` runs every check below; the alias in `mix.exs`
  is the list. Green gate is the definition of done for every change, and a check
  outside the gate is skipped by the first agent in a hurry.
- **Contract.** `live_vue_contract` types the boundary between LiveView and Vue
  from the TypeScript side: `defineProps<T>()` for props, `useLiveEvents<T>()`
  for what `pushEvent` sends and what `handle_event` replies. A `<.vue>` tag
  that drifts from its component fails `mix compile`; a nested key, a payload or
  a reply that drifts fails the test that renders or pushes it. Its coverage
  report at the end of `mix test` names the components and events no test
  exercised. `strict: true`, the contract committed, every `pushEvent` through
  `useLiveEvents`. A gate that splits `mix test` into `--partitions` ends with
  `mix live_vue_contract.coverage`, which merges the partitions into one report
  (the release after 0.4.0).
- **Typed client.** `tsconfig.json` with `strict: true`, every `.vue` file with
  `<script setup lang="ts">`. Logic a component computes on the client
  (formatting, sorting, a game rule) lives in a plain `.ts` module with a vitest
  test beside it.
- **Client lint**, configs in `templates/lint/`: oxlint for JS and TS
  correctness; oxlint type-aware for promises and exhaustive switches in `.ts`;
  ESLint for what those skip, the Vue template, its accessibility, and the same
  type rules for `<script>` in `.vue`; Stylelint for invalid CSS and `@apply`;
  knip for dead files, exports and dependencies; dependency-cruiser for import
  cycles and the `components/ui` → product direction. The rule that pays first
  is `no-floating-promises`: an unawaited `pushEvent` drops its rejection
  silently.
- **Architecture checks.** `credo --strict` with the project checks in
  `templates/credo/checks/`: `Repo` called only from the files `.credo.exs`
  lists with a reason, every Ash domain declaring its boundary, 600 lines per
  file. `boundary` declares the domain graph: each domain names the domains it
  calls, the core never calls the web layer, and an undeclared call or a cycle is
  a compiler warning, so the gate fails on it. Both start on day one: added to a
  project after its first eight slices, `boundary` found 158 undeclared calls
  between domains and two cycles.
- **Eyes.** Playwright and `bin/shot.mjs` screenshot any page as any user,
  through the `/dev/login/:name` route that exists only in dev. An agent checks a
  screen by looking at the screenshot, not by reading the template.
- **Project instructions** are a hand-written `CLAUDE.md`: the product glossary
  (the words the owner uses ↔ module and route names), the gate, how to look at a
  screen, and pointers to `docs/`. UsageRules writes only skills; a rules file it
  generates is never read by Claude Code.
- **Skill reminders.** A `PreToolUse` hook names the skill to load when an edit
  touches an Ash resource or a Vue file. A line in `CLAUDE.md` saying the same
  is forgotten by the tenth edit; the hook arrives at the edit.

## Deployment

The release is a Docker image, built and published by CI from
`templates/deploy/image.yml`: on each push to the main branch it builds the
image, runs its migrations and boots it against a throwaway PostgreSQL, checks
`/health`, and pushes it. CI is where the image is proved: a local build
depends on the network to Hex, npm and the base image registry, and fails there
more often than on the code.

- Images are tagged with the Git SHA. `latest` is a convenience alias, never what
  a running service is pinned to.
- Builds run from a pushed commit: a SHA that exists only on one machine cannot
  be reproduced or rolled back to.
- The healthcheck needs a `/health` plug in the endpoint, ahead of the whole
  stack and without a database call, and `curl` in the runner image.
- Required runtime variables fail the deploy when unset (`${VAR:?}` in a stack
  file, a required secret in a manifest), so a misconfigured release never boots
  half-configured.

Analysis §12 picks the runtime profile; each is a policy choice, and a runtime
outside the three is a §12 Deviation.

- **Swarm**, the default: `deploy/stack.yml` and the `Makefile` from
  `templates/deploy/`. Updates run `order: start-first` with the healthcheck
  and `failure_action: rollback`, so a failed release never takes the service
  down. A panel that consumes stack files can deploy it, and so can
  `DOCKER_HOST=ssh://host docker stack deploy`.
- **Kubernetes**, when the organisation runs a cluster: the artefact takes the
  shape the cluster's owners use (plain manifests, a Helm chart, a GitOps
  repository), with readiness and liveness probes on `/health` and a rolling
  update. §12 names the owners and where their conventions are written; with the
  conventions unknown, §15 asks the owners and the artefact waits for the answer.
- **Native**: a release outside a container, a `systemd --user` service for a
  desktop-integrated product for example, configured and verified per
  `NATIVE_RUNTIME.md`. It has no image, so the image workflow stays out.
