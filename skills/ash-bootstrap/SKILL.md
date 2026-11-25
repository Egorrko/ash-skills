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
- `INSTALLER_DEFECTS.md`: known defects with workarounds, all applied in the starter; they matter for packages installed on top of it and for a starter refresh;
- `NATIVE_RUNTIME.md`: configuration and verification for a release that runs outside a container, read when §12 names such a runtime;
- `STARTER.md`: what the starter contains and how it is refreshed;
- `MANUAL_BOOTSTRAP.md`: generators and harness by hand, for a replaced UI layer and for a starter refresh.

Long command output goes to files in the scratchpad, and only the lines that matter come back into context. Write the scratchpad path literally in each redirect, or put a multi-step check in a script file there and run it: the shell guard blocks redirects to `$VAR` paths.

## B0. Toolchain

```bash
elixir --version; mix --version; node --version; npm --version; git --version
docker info >/dev/null 2>&1 && echo "docker: ok" || echo "docker: unavailable"
pg_isready -h 127.0.0.1 -p 5432 || echo "postgres: no server on 5432"
```

Elixir, mix, node, or git missing: stop and report. Docker missing: continue, and the handoff records which checks this blocks. PostgreSQL needs a reachable server, not only a client: an inactive system service and a running `postgres` container are both common, and `docker ps` finds the second. With neither, start one: `docker run -d --name pg -p 5432:5432 -e POSTGRES_HOST_AUTH_METHOD=trust postgres`. Versions and the server used go into the analysis metadata.

## B1. Create from the starter

Fill analysis §11 from `ASH_FEATURES.md`: every optional feature cites the analysis section whose behavior requires it, so the section stands as the justification list.

The project starts as a copy of `${CLAUDE_SKILL_DIR}/starter/`, a verified Phoenix + Ash + LiveVue project with every `INSTALLER_DEFECTS.md` workaround applied, the component layer, the whole quality harness, `/health`, `bin/shot.mjs`, `bin/verify` and a Dockerfile, at locked versions (`mix.lock`, `package-lock.json`). Its contents: `STARTER.md`.

```bash
${CLAUDE_SKILL_DIR}/bin/new-app <target path from the metadata>
```

It renames the app, generates secrets, picks free dev ports (printed; `PORT` and `VITE_PORT` override them), fetches deps (retrying through a local proxy when hex.pm is unreachable), creates the dev database, builds assets and makes the first commit, in about two minutes. A failure prints the step and the tail of `log/new-app.log`. Record the command in §14.

Then install the §11 features the starter lacks (the starter has ash, ash_phoenix, ash_postgres, ash_oban, oban_web, usage_rules, live_vue): one `mix igniter.install <packages> --yes` with the packages from `ASH_FEATURES.md`, then `mix compile` and `mix ash.codegen --check`. Only here do `INSTALLER_DEFECTS.md` entries still apply: read the ones naming the installed packages. Each new Ash domain gets `use Boundary, deps: [<the domains it calls>], exports: :all`.

A §12 Deviation that replaces the UI layer leaves the starter: follow `references/MANUAL_BOOTSTRAP.md` for B1–B3 instead, and the handoff says so.

## B2. Project knowledge

`mix usage_rules.sync --yes`: picks up the skills of the packages B1 added.

Write `CLAUDE.md` from `${CLAUDE_SKILL_DIR}/templates/claude/CLAUDE.md`, every `<...>` filled from the analysis: the glossary from §1, the source path for a replatform. The starter already has `.claude/hooks/skill-reminder.sh` and `.claude/settings.json`.

Copy `${CLAUDE_SKILL_DIR}/templates/NEXT_SLICE_SKILL.md` to `.claude/skills/next-slice/SKILL.md`. Replace `<SOURCE_PATH>` with the source checkout's absolute path; for a new product, delete the paragraphs that name it.

The starter carries the shadcn-vue primitives button, badge, card, input and switch. Add only those the first slice in §13 needs beyond them: `npx shadcn-vue@latest add <name> --yes`, then `grep -r 'from "cn"' assets/components` and `npm ls cn` find nothing (`INSTALLER_DEFECTS.md`), and a primitive knip calls unused is removed until a slice uses it.

## B3. Product-specific harness

The harness itself is in the starter and was proven when the starter was built (`STARTER.md`): each part turned red on its planted mistake. Per project only:

1. **Dev login.** With authentication in §6, add the dev-only route `GET /dev/login/:name` under the `dev_routes` scope: it finds or creates the user with that name through the product's own Ash actions, signs them in the way the product's strategy does, and redirects to `return_to`. Check: `node bin/shot.mjs <a page that shows who is signed in> out.png --as alice`; read the image.
2. **Ports.** `config/runtime.exs`, `config/dev.exs`, `assets/vite.config.mjs` and `bin/shot.mjs` carry the dev ports `new-app` picked. A product port from §12 (a release on a fixed port) goes into `.env.example` and the runtime artefact, not into these defaults.

## B4. Verify

`bin/verify` runs the gate (`mix precommit`), the prod asset build and compile, and boots the release against a scratch database until `/health` answers 200; `bin/verify --docker` adds the image build (run it in the background: about ten minutes). Its summary is the verdict for the rows it covers; a FAIL line names its log.

Run every other row of the Verification table in `${CLAUDE_SKILL_DIR}/templates/HANDOFF.md`, top to bottom, with the commands it lists, and record each verdict: passed, failed, or not verified with the reason. Where a dependency version was overridden or a security advisory forced an upgrade, exercise the affected code path at runtime: an override compiles cleanly and still breaks an HTTP adapter. A local image build that fails fetching from Hex, npm or the base image registry is `not verified: network`, with the failing line; the CI workflow is that row's check once the repository has a remote.

The deployment artefact follows the runtime profile in analysis §12 (`STACK_POLICY.md`, "Deployment"):

- Swarm and Kubernetes: `templates/deploy/image.yml` to `.github/workflows/image.yml`, `<APP>` filled, and every variable `config/runtime.exs` requires added to its `env` with a throwaway value. A registry other than GHCR replaces the image name and the login step.
- Swarm: `templates/deploy/stack.yml` to `deploy/stack.yml` and `templates/deploy/Makefile` to the project root, `<APP>` and `<REGISTRY>` replaced with the values from §12, every runtime variable from `.env.example` carried into the stack file, required ones with `:?`. A registry §12 leaves unknown stays as the literal `<REGISTRY>` placeholder and goes into the open questions.
- Kubernetes: the artefact in the shape §12 records for the organisation's cluster, under `deploy/`, with readiness and liveness probes on `/health`, a rolling update, and the required variables as required secrets. Conventions §12 leaves unknown: `deploy/` holds a `README.md` naming what the cluster's owners must answer, and the question goes into the open questions.
- Native: follow `${CLAUDE_SKILL_DIR}/references/NATIVE_RUNTIME.md`, and delete the starter's `Dockerfile` and `.dockerignore`. Its artefact goes into `deploy/` (a `systemd --user` unit, for example) with install steps in its header comment, and the release boots under it.

The bootstrap deploys nothing.

Commit the bootstrap on top of the starter's first commit:

```bash
git add -A && git commit -m "chore: bootstrap Phoenix + Ash + LiveVue target"
```

That revision is the target revision in the handoff.

## B5. Handoff and stop

Copy the analysis into the target as `docs/PRODUCT_ANALYSIS.md`, and the workspace `notes/` directory, when it exists, as `docs/notes/`. Write `docs/BOOTSTRAP_HANDOFF.md` from `${CLAUDE_SKILL_DIR}/templates/HANDOFF.md` with every field filled; the open-questions queue starts from analysis §15, each entry stating what it blocks. Commit:

```bash
git add docs && git commit -m "docs: product analysis and bootstrap handoff"
```

An installation obstacle that any project on this stack would hit, independent of this product's own dependencies, is a candidate for `INSTALLER_DEFECTS.md` and for a fix in `starter/` (an obstacle the starter could have avoided is a starter fix first); a known entry that reproduced or stopped reproducing is an update to its version line. Put each candidate to the user as its own question, separate from the final report, with the exact entry (symptom, versions, workaround, how to verify); the skill changes only on their acceptance.

End here. Tell the user to start a new Claude Code session from the target root and run `/next-slice`: the restart is what loads the generated project instructions and skills as context. With authentication, give them the dev login, `http://localhost:<PORT>/dev/login/<name>` with the port `new-app` printed, so they can open any screen as any user while `mix phx.server` runs.
