# The Phoenix + Ash + LiveVue stack

The target stack shared by every project the bootstrap creates.

## Foundation

Elixir and OTP, Phoenix, Ash, PostgreSQL through AshPostgres, Phoenix LiveView,
LiveVue, UsageRules.

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
  under that setting, not only in development.

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
- External and mobile API contracts that remain part of the product are preserved.
- Every optional dependency is justified by a concrete behavior in the analysis;
  `ASH_FEATURES.md` is the catalog and the selection rules.

## Quality harness

The owner of a project on this stack watches tests and behavior, not code. The
harness is what makes that enough: every class of mistake an agent makes turns
the **gate** red, so the agent sees it and fixes it before anyone else does. A
mistake no check catches reaches the user.

- **One gate.** `mix precommit` runs everything: `compile --warnings-as-errors`,
  `deps.unlock --unused`, `format`, `vue-tsc --noEmit`, `vitest run`, `mix test`.
  Green gate is the definition of done for every change; a check that lives
  outside it is skipped by the first agent in a hurry.
- **Props contract.** `live_vue_contract` makes the boundary between `<.vue>`
  and `defineProps<T>()` typed: `strict: true`, the contract committed. A prop
  missing, renamed, or added on one side only fails compilation or the test that
  renders it. Every screen is a LiveVue component, so this boundary is where the
  server and the client drift apart first.
- **Typed client.** `tsconfig.json` with `strict: true`, every `.vue` file with
  `<script setup lang="ts">`, props typed in `defineProps<T>()`. Logic a
  component computes on the client (formatting, sorting, a game rule) lives in a
  plain `.ts` module with a vitest test beside it.
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

The default runtime is a Docker image published to a registry and deployed as a
Docker Swarm stack, from the templates in `templates/deploy/`. Analysis §12 may
name another runtime with the reason (a desktop-integrated product runs as a
`systemd --user` service from a release, for example); the bootstrap then
produces that runtime's artefact instead of the stack file and verifies the
release under it.

- Images are tagged with the Git SHA. `latest` is a convenience alias, never what
  a running service is pinned to.
- Builds run from a clean, pushed tree: a SHA that exists only on one machine
  cannot be reproduced or rolled back to.
- Updates run `order: start-first` with a healthcheck and `failure_action:
  rollback`, so a failed release never takes the service down. The healthcheck
  needs a `/health` plug in the endpoint and `curl` in the runner image.
- The stack file is plain Swarm. A panel that consumes stack files can deploy
  it, and so can `DOCKER_HOST=ssh://host docker stack deploy`; choose per project.
- Required runtime variables use `${VAR:?}` so a misconfigured deploy fails
  loudly instead of booting half-configured.
