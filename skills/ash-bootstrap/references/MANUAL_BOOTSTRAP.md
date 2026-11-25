# Manual bootstrap: generators and the harness by hand

The path `SKILL.md` B1–B3 replaces with the starter. Two cases still use it: a §12 Deviation that replaces the UI layer (the starter is LiveVue-only), and a starter refresh (`STARTER.md`). Each step is checked as written; `INSTALLER_DEFECTS.md` applies to every generator run.

## M1. Select and install

Fill analysis §11 from `ASH_FEATURES.md`: every optional feature cites the analysis section whose behavior requires it, so the section stands as the justification list.

Build the command from the installer grammar, confirm it against `mix help igniter.new` and each installer's help, and record it in §14 before running it. Create the target at the path in the metadata. Then run the LiveVue installer, unless §12 Deviations replaces the UI layer, then the remaining installers. Re-read `INSTALLER_DEFECTS.md` before the asset setup: several entries bite there rather than at project creation.

## M2. Project knowledge

After the final dependency is installed, add the `usage_rules` project config from `${CLAUDE_SKILL_DIR}/templates/usage_rules.exs` to `mix.exs`, then:

```bash
mix usage_rules.sync --yes
```

The composed skills land in `.claude/skills/`, and no rules file appears: Claude Code reads `CLAUDE.md`, written next.

Write `CLAUDE.md` from `${CLAUDE_SKILL_DIR}/templates/claude/CLAUDE.md`, every `<...>` filled from the analysis: the glossary from §1, the source path for a replatform. Copy `templates/claude/hooks/skill-reminder.sh` (executable) and `templates/claude/settings.json` into the target's `.claude/`. Check: `echo '{"tool_input":{"file_path":"'$PWD'/assets/vue/x.vue"}}' | .claude/hooks/skill-reminder.sh` names `live-vue`.

With the UI layer replaced in §12 Deviations, the component layer below is replaced too: the `live-vue` skill leaves the `usage_rules` config and the hook, and the root layout and base stylesheet follow the client constraints in §9. Otherwise install the component layer from `STACK_POLICY.md` by hand, since shadcn-vue's own init refuses a Phoenix project (`INSTALLER_DEFECTS.md`):

1. `npm install reka-ui class-variance-authority clsx tailwind-merge tw-animate-css @lucide/vue @vueuse/core`
2. `${CLAUDE_SKILL_DIR}/templates/shadcn/components.json` to the project root; `templates/shadcn/utils.ts` to `assets/lib/utils.ts`.
3. In `tsconfig.json` map `@/*` to `./assets/*`.
4. In `assets/css/app.css`: `@import "tw-animate-css";` after the tailwind import, `@source "../components";` beside the other `@source` lines (phx.new imports tailwind with `source(none)`, so the shadcn primitives are not scanned otherwise), and the contents of `templates/shadcn/theme.css` appended. The theme hangs its dark variables off `[data-theme=dark]`, which phx.new already defines.
5. `npx shadcn-vue@latest add button --yes`, and only the further primitives the first slice in §13 needs. The check: `assets/components/ui/button/` exists, imports `cn` from `@/lib/utils` (the `cn` rewrite in `INSTALLER_DEFECTS.md`), and `MIX_ENV=prod mix assets.build` passes.

Let a second copy of the project run its dev server beside the first, since parallel sessions each work in their own copy: `config/dev.exs` reads `VITE_PORT` (default 5173) into LiveVue's `vite_host`; `assets/vite.config.mjs` takes `server.port` from `VITE_PORT` with `strictPort: true` and allows `http://localhost:${PORT ?? 4000}` in `server.cors`. Check: `PORT=4011 VITE_PORT=5183 mix phx.server` serves `/` with its assets while another server holds 4000 and 5173.

Copy `${CLAUDE_SKILL_DIR}/templates/NEXT_SLICE_SKILL.md` to `.claude/skills/next-slice/SKILL.md` in the target. Replace `<SOURCE_PATH>` with the source checkout's absolute path; for a new product, delete the paragraphs that name it. With the UI layer replaced, its LiveVue wording names the replacement.

## M3. Quality harness

The harness in `STACK_POLICY.md`, "Quality harness", installed and proven: each part ends on a check that plants the mistake it exists for and watches the gate go red. A part §12 Deviations removes (no Vue layer, no contract) is skipped and the handoff says so.

1. **Contract.** `{:live_vue_contract, "~> 0.5"}` in deps; `compilers: [:live_vue_contract, :phoenix_live_view] ++ Mix.compilers()` in `project/0`; in the `html_helpers` of `lib/<app>_web.ex`, `use LiveVueContract` replaces `use LiveVue` and `use LiveVue.Components`; `config :live_vue_contract, strict: true` in `config/config.exs`; `LiveVueContract.Coverage.start()` above `ExUnit.start()` in `test/test_helper.exs`. Client side: `"live_vue_contract": "file:./deps/live_vue_contract"` in `package.json` dependencies, then `npm install` and `npm install -D vue-component-meta@<the installed vue-tsc version> vue-tsc typescript`. `mix compile` writes `assets/vue/contract.json`, which is committed. Check: a `<.vue>` tag given a prop its component does not declare fails `mix compile` naming it; `mix test` ends with the `live_vue_contract:` coverage line; revert.
2. **Typed client.** `"strict": true` in `tsconfig.json`. Check: `npx vue-tsc --noEmit` passes, and fails on a `const n: number = "x"` added to a component; revert.
3. **Client tests.** `npm install -D vitest jsdom`, a `vitest.config.mjs` that includes `assets/**/*.test.ts`, and a first test beside `assets/lib/utils.ts`. Check: `npx vitest run` passes.
4. **Client lint.** `npm install -D oxlint oxlint-tsgolint eslint eslint-plugin-vue eslint-plugin-vuejs-accessibility vue-eslint-parser typescript-eslint stylelint stylelint-config-recommended postcss-html knip dependency-cruiser`. Copy every file of `${CLAUDE_SKILL_DIR}/templates/lint/`, dotfiles included, to the project root. Add the scripts to `package.json`:

   ```json
   "lint": "oxlint assets",
   "lint:types": "oxlint --type-aware -c .oxlintrc.types.json assets/js assets/lib assets/vue",
   "lint:vue": "eslint assets",
   "lint:css": "stylelint \"assets/**/*.{css,vue}\"",
   "knip": "knip --no-progress",
   "depcruise": "depcruise assets/js assets/vue --output-type err",
   "lint:all": "npm run -s lint && npm run -s lint:types && npm run -s lint:vue && npm run -s lint:css && npm run -s knip && npm run -s depcruise"
   ```

   The first run reports the installers' own output: each `@import` in `assets/css/app.css` moves above the first `@source` line, and each dependency knip calls unused is either imported somewhere or removed. Check: `npm run lint:all` exits 0, and turns red on each of these, reverted one by one: a bare `Promise.resolve()` statement in a `.vue` script, the same in a `.ts` module, an `@apply` in `app.css`, an exported function nothing imports.
5. **Architecture checks.** `{:credo, "~> 1.7", only: [:dev, :test], runtime: false}` and `{:boundary, "~> 0.12", runtime: false}` in deps; `:boundary` first in `compilers`. Copy `templates/credo/credo.exs` to `.credo.exs` with `<app>` filled, and `templates/credo/checks/` to `credo/checks/`. Declare the boundaries:
   - `lib/<app>.ex`: `use Boundary, deps: [], exports: :all`;
   - `lib/<app>_web.ex`: `use Boundary, deps: [<App>], exports: [Endpoint]`;
   - `lib/<app>/application.ex`: `use Boundary, top_level?: true, deps: [<App>, <App>Web]`;
   - each Ash domain: `use Boundary, deps: [<the domains it calls>], exports: :all`.

   The first `mix credo --strict` on generated code: fix each finding, or exclude the generated file in `.credo.exs` with the reason. Check: `mix credo --strict` and `mix compile --warnings-as-errors` pass, and each of these turns one of them red, reverted one by one: `<App>.Repo.all(...)` in a file under `lib/<app>/`, a domain without `use Boundary`, a reference from `lib/<app>/` to `<App>Web.Endpoint`.
6. **The gate.** The `precommit` alias phx.new wrote becomes, in this order: `"compile --warnings-as-errors"`, `"deps.unlock --unused"`, `"format"`, `"credo --strict"`, `"assets.build"` while the asset manifest defect in `INSTALLER_DEFECTS.md` reproduces, `"cmd npx vue-tsc --noEmit"`, `"cmd npm run -s lint:all"`, `"cmd npx vitest run"`, `"test"`. Check: `mix precommit` exits 0.
7. **Eyes.** `npm install -D playwright && npx playwright install chromium`; `${CLAUDE_SKILL_DIR}/templates/bin/shot.mjs` to `bin/shot.mjs`. With authentication in §6, add the dev-only route `GET /dev/login/:name` under the `dev_routes` scope: it finds or creates the user with that name through the product's own Ash actions, signs them in the way the product's strategy does, and redirects to `return_to`. Check: `node bin/shot.mjs / out.png` and, with authentication, `--as` on a page that shows who is signed in; read both images.

