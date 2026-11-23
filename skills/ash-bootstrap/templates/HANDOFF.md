# Bootstrap handoff

## Paths and revisions

- Origin: source path and revision | new product
- Target path:
- Target revision (the bootstrap commit; this file lands in the next one):

## Toolchain

- Elixir/OTP, mix, node, npm, git versions:
- Docker available: yes/no
- PostgreSQL server used:
- Verification steps blocked by missing tools:

## Selected target stack

Installed packages and the analysis section each one serves.

## Exact bootstrap command

```bash
# exact command used
```

## Setup performed

Authentication providers, integrations, runtime variables, generated
configuration, frontend setup. Each §12 deviation with the bootstrap steps it
replaced.

## Installation obstacles

Anything that did not install or compile on the first attempt: the symptom, the
package versions involved, and what resolved it. Known defects that reproduced
are listed by name. Empty is a valid answer.

## Deployment

- Runtime profile per analysis §12 (Swarm, Kubernetes, native):
- Artefact written (`deploy/stack.yml` + `Makefile`, the cluster's manifests, or the runtime's own unit):
- Image workflow: `.github/workflows/image.yml`, or `not applicable` (native):
- Registry and image name, or `not applicable`:
- Required runtime variables:
- Nothing has been deployed by the bootstrap.

## Project instructions, skills and harness

- `CLAUDE.md` written from the template; glossary terms carried from analysis §1:
- Composed project skills and the packages contributing to each:
- Skill reminder hook in `.claude/settings.json`:
- Harness parts installed, or skipped with the §12 deviation that removes them:

## Verification

Each check gets a verdict: **passed**, **failed**, or **not verified** with the
reason. A skipped check is not verified. The image rows apply to the Swarm and
Kubernetes profiles; a native runtime replaces them with its own boot check. An
image row that fails on the network reads `not verified: network` with the
failing line, and the image workflow is its check once the repository has a remote.

| Check | Command | Verdict |
| --- | --- | --- |
| Dependency fetch | `mix deps.get` | |
| Compilation | `mix compile --warnings-as-errors` and `MIX_ENV=prod mix compile --warnings-as-errors` | |
| Formatting | `mix format` then `mix format --check-formatted` | |
| Database creation and migrations | `mix ash.setup` | |
| Production asset build | `MIX_ENV=prod mix assets.build` | |
| Generated tests | `mix assets.build && mix test` | |
| Contract catches drift | `mix compile` writes `assets/vue/contract.json`; an undeclared prop on a `<.vue>` tag fails it; `mix test` prints the coverage line | |
| Client type check catches errors | `npx vue-tsc --noEmit` passes, fails on a planted type error | |
| Client tests | `npx vitest run` | |
| Client lint catches errors | `npm run lint:all` passes, fails on each planted mistake in B3 | |
| Architecture checks catch errors | `mix credo --strict` and `mix compile --warnings-as-errors` pass, fail on each planted mistake in B3 | |
| The gate | `mix precommit` | |
| Screenshots | `node bin/shot.mjs / out.png`, and `--as <name>` with authentication | |
| Development server boot | `mix phx.server`; `curl` on `/` and `/health` | |
| Release files | `mix phx.gen.release --docker` | |
| OTP release build | `MIX_ENV=prod mix release` | |
| Docker image build (image) | `docker build -t <app>:bootstrap .` | |
| Release migrations from the image (image) | `docker run ... <app>:bootstrap /app/bin/migrate` | |
| Container boot and `/health` (image) | `docker run -d ...`; `curl` on `/health` | |
| Image workflow is valid (image) | `.github/workflows/image.yml` parses; its `env` carries every variable `runtime.exs` requires | |
| Release boot under the product's runtime (other) | the unit or command from §12; `curl` on `/health` | |
| LAN reachability (a §9 client on another device) | `curl` on `/health` from the host's LAN address | |
| Client compatibility (a §9 client with a constrained browser) | the bundle target and stylesheet checked against the client per §12 Deviations | |
| `.env.example` and startup documentation | | |

## First vertical slice

The agreed first slice, copied from the analysis.

## Open questions

The queue of unresolved decisions. Each entry states what it **blocks**: the
slice that cannot be built until it is answered, or `nothing yet`. Answered
entries stay, marked resolved with the answer and the slice that settled it.

```text
- [ ] 1. <question> — blocks: <slice, or "nothing yet">
- [x] 2. <question> — resolved in slice 3: <the decision>
```

## Continuing from here

Start a new Claude Code session from this repository root, so the generated
project instructions and skills load as context, and run:

```text
/next-slice
```

It reads this handoff and the analysis, implements the first vertical slice end
to end, verifies it, and commits. Run it again for each following slice, or name
one with `/next-slice <slice>`; a request outside the analysis becomes a slice
the same way.

Dev login, with authentication: while `mix phx.server` runs, open
`http://localhost:4000/dev/login/<name>` to see any screen as that user.
