---
name: ash-bootstrap
description: Build the Phoenix + Ash + LiveVue target described by a finished PRODUCT_ANALYSIS.md, verify it to a running release, write the handoff, and stop.
argument-hint: "[path/to/PRODUCT_ANALYSIS.md]"
disable-model-invocation: true
---

# Bootstrap the target project

The input is a `PRODUCT_ANALYSIS.md` written by `/replatform-to-ash` or `/new-ash-project`: at `$ARGUMENTS`, else in the current directory, else in its parent. Its metadata names the target application and path; its §12 names the runtime. Running this skill is the user's confirmation of the analysis. With no analysis, stop and name the two skills that write one.

Analysis §12 **Deviations** is the one list of places where this product leaves `STACK_POLICY.md` (the runtime, the UI layer, a dependency). A step a deviation covers is replaced by what the deviation names, and the handoff says which steps changed and why.

Its progress block is the progress record: tick a bootstrap item the moment it finishes. A rerun continues from the first unticked item after confirming the recorded state against the filesystem, in the existing target directory.

Reference for the whole run, in `${CLAUDE_SKILL_DIR}/references/`:

- `STACK_POLICY.md`: the stack and its rules;
- `ASH_FEATURES.md`: installer grammar, feature keys, when to select each;
- `INSTALLER_DEFECTS.md`: known defects with workarounds. Each names the versions it was seen on; a workaround applies only after the defect reproduces here;
- `NATIVE_RUNTIME.md`: configuration and verification for a release that runs outside a container, read when §12 names such a runtime.

Long command output goes to files in the scratchpad, and only the lines that matter come back into context. Write the scratchpad path literally in each redirect, or put a multi-step check in a script file there and run it: the shell guard blocks redirects to `$VAR` paths.

## B0. Toolchain

```bash
elixir --version; mix --version; node --version; npm --version; git --version
docker info >/dev/null 2>&1 && echo "docker: ok" || echo "docker: unavailable"
pg_isready -h 127.0.0.1 -p 5432 || echo "postgres: no server on 5432"
```

Elixir, mix, node, or git missing: stop and report. Docker missing: continue, and the handoff records which checks this blocks. PostgreSQL needs a reachable server, not only a client: an inactive system service and a running `postgres` container are both common, and `docker ps` finds the second. With neither, start one: `docker run -d --name pg -p 5432:5432 -e POSTGRES_HOST_AUTH_METHOD=trust postgres`. Versions and the server used go into the analysis metadata.

## B1. Select and install

Fill analysis §11 from `ASH_FEATURES.md`: every optional feature cites the analysis section whose behavior requires it, so the section stands as the justification list.

Build the command from the installer grammar, confirm it against `mix help igniter.new` and each installer's help, and record it in §14 before running it. Create the target at the path in the metadata. Then run the LiveVue installer, unless §12 Deviations replaces the UI layer, then the remaining installers. Re-read `INSTALLER_DEFECTS.md` before the asset setup: several entries bite there rather than at project creation.

## B2. Project knowledge

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
4. In `assets/css/app.css`: `@import "tw-animate-css";` after the tailwind import, and the contents of `templates/shadcn/theme.css` appended. The theme hangs its dark variables off `[data-theme=dark]`, which phx.new already defines.
5. `npx shadcn-vue@latest add button --yes`, and only the further primitives the first slice in §13 needs. The check: `assets/components/ui/button/` exists and `MIX_ENV=prod mix assets.build` passes.

Let a second copy of the project run its dev server beside the first, since parallel sessions each work in their own copy: `config/dev.exs` reads `VITE_PORT` (default 5173) into LiveVue's `vite_host`; `assets/vite.config.mjs` takes `server.port` from `VITE_PORT` with `strictPort: true` and allows `http://localhost:${PORT ?? 4000}` in `server.cors`. Check: `PORT=4011 VITE_PORT=5183 mix phx.server` serves `/` with its assets while another server holds 4000 and 5173.

Copy `${CLAUDE_SKILL_DIR}/templates/NEXT_SLICE_SKILL.md` to `.claude/skills/next-slice/SKILL.md` in the target. Replace `<SOURCE_PATH>` with the source checkout's absolute path; for a new product, delete the paragraphs that name it. With the UI layer replaced, its LiveVue wording names the replacement.

## B3. Quality harness

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

## B4. Verify

Add a `/health` plug to the endpoint, ahead of the whole stack and without a database call, and `curl` to the Dockerfile runner stage: every runtime profile's healthcheck depends on both.

Run every row of the Verification table in `${CLAUDE_SKILL_DIR}/templates/HANDOFF.md`, top to bottom, with the commands it lists, and record each verdict: passed, failed, or not verified with the reason. Where a dependency version was overridden or a security advisory forced an upgrade, exercise the affected code path at runtime: an override compiles cleanly and still breaks an HTTP adapter. A local image build that fails fetching from Hex, npm or the base image registry is `not verified: network`, with the failing line; the CI workflow is that row's check once the repository has a remote.

The deployment artefact follows the runtime profile in analysis §12 (`STACK_POLICY.md`, "Deployment"):

- Swarm and Kubernetes: `templates/deploy/image.yml` to `.github/workflows/image.yml`, `<APP>` filled, and every variable `config/runtime.exs` requires added to its `env` with a throwaway value. A registry other than GHCR replaces the image name and the login step.
- Swarm: `templates/deploy/stack.yml` to `deploy/stack.yml` and `templates/deploy/Makefile` to the project root, `<APP>` and `<REGISTRY>` replaced with the values from §12, every runtime variable from `.env.example` carried into the stack file, required ones with `:?`. A registry §12 leaves unknown stays as the literal `<REGISTRY>` placeholder and goes into the open questions.
- Kubernetes: the artefact in the shape §12 records for the organisation's cluster, under `deploy/`, with readiness and liveness probes on `/health`, a rolling update, and the required variables as required secrets. Conventions §12 leaves unknown: `deploy/` holds a `README.md` naming what the cluster's owners must answer, and the question goes into the open questions.
- Native: follow `${CLAUDE_SKILL_DIR}/references/NATIVE_RUNTIME.md`. Its artefact goes into `deploy/` (a `systemd --user` unit, for example) with install steps in its header comment, and the release boots under it.

The bootstrap deploys nothing.

Put the target under version control, unless the generator already committed:

```bash
git init && git add -A && git commit -m "chore: bootstrap Phoenix + Ash + LiveVue target"
```

That revision is the target revision in the handoff.

## B5. Handoff and stop

Copy the analysis into the target as `docs/PRODUCT_ANALYSIS.md`, and the workspace `notes/` directory, when it exists, as `docs/notes/`. Write `docs/BOOTSTRAP_HANDOFF.md` from `${CLAUDE_SKILL_DIR}/templates/HANDOFF.md` with every field filled; the open-questions queue starts from analysis §15, each entry stating what it blocks. Commit:

```bash
git add docs && git commit -m "docs: product analysis and bootstrap handoff"
```

An installation obstacle that any project on this stack would hit, independent of this product's own dependencies, is a candidate for `INSTALLER_DEFECTS.md`; a known entry that reproduced or stopped reproducing is an update to its version line. Put each candidate to the user as its own question, separate from the final report, with the exact entry (symptom, versions, workaround, how to verify); the skill changes only on their acceptance.

End here. Tell the user to start a new Claude Code session from the target root and run `/next-slice`: the restart is what loads the generated project instructions and skills as context. With authentication, give them the dev login, `http://localhost:4000/dev/login/<name>`, so they can open any screen as any user while `mix phx.server` runs.
