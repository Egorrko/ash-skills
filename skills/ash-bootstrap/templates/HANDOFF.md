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

- Runtime per analysis §12:
- Artefact written (`deploy/stack.yml` + `Makefile`, or the runtime's own unit):
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
reason. A skipped check is not verified. The Swarm rows apply when §12 keeps the
default runtime; another runtime replaces them with its own boot check.

| Check | Command | Verdict |
| --- | --- | --- |
| Dependency fetch | `mix deps.get` | |
| Compilation | `mix compile --warnings-as-errors` and `MIX_ENV=prod mix compile --warnings-as-errors` | |
| Formatting | `mix format` then `mix format --check-formatted` | |
| Database creation and migrations | `mix ash.setup` | |
| Production asset build | `MIX_ENV=prod mix assets.build` | |
| Generated tests | `mix assets.build && mix test` | |
| Props contract catches drift | `mix compile` writes `assets/vue/contract.json`; an undeclared prop on a `<.vue>` tag fails it | |
| Client type check catches errors | `npx vue-tsc --noEmit` passes, fails on a planted type error | |
| Client tests | `npx vitest run` | |
| The gate | `mix precommit` | |
| Screenshots | `node bin/shot.mjs / out.png`, and `--as <name>` with authentication | |
| Development server boot | `mix phx.server`; `curl` on `/` and `/health` | |
| Release files | `mix phx.gen.release --docker` | |
| OTP release build | `MIX_ENV=prod mix release` | |
| Docker image build (Swarm) | `docker build -t <app>:bootstrap .` | |
| Release migrations from the image (Swarm) | `docker run ... <app>:bootstrap /app/bin/migrate` | |
| Container boot and `/health` (Swarm) | `docker run -d ...`; `curl` on `/health` | |
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
one with `/next-slice <slice>`.
