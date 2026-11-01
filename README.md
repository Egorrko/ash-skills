# ash-skills

Claude Code skills that take a product, from an idea or from an existing app, to a
Phoenix + Ash + LiveVue repository built for an owner who reads tests and behavior
rather than code, then implement it slice by slice.

```
/replatform-to-ash  (from a source repo root)  ─┐
                                                 ├─→ PRODUCT_ANALYSIS.md ─→ /ash-bootstrap ─→ target repo ─→ /next-slice, per slice
/new-ash-project    (from an empty workspace)  ─┘
```

- `/replatform-to-ash` reads an existing app, backend or frontend-only (Supabase, Firebase,
  a third-party API), screenshots every screen, and writes the analysis: domain model,
  rules with `file:line` evidence, the target architecture, a first vertical slice.
- `/new-ash-project` designs a new product with you through an interview and writes the
  same analysis.
- `/ash-bootstrap` creates the target with the latest generators, installs the stack and
  its quality harness, verifies it to a running release, and writes a handoff.
- `/next-slice`, installed into the target, implements one user-visible slice at a time:
  Ash resources to Vue screens, verified by the gate and by screenshots, committed.

## The stack

Elixir, Phoenix, Ash with AshPostgres, LiveView hosting LiveVue: every screen is a Vue
component, shadcn-vue on Tailwind. Optional Ash extensions are selected only when the
analysis names a behavior that needs them. Deployment defaults to a Docker image on a
Swarm stack. Full policy: [`STACK_POLICY.md`](skills/ash-bootstrap/references/STACK_POLICY.md).

The quality harness is what lets you not read the code: every class of agent mistake
turns one gate, `mix precommit`, red.

- **Props contract**: [`live_vue_contract`](https://github.com/Egorrko/live_vue_contract)
  checks `<.vue>` tags against `defineProps<T>()` at compile time and in tests, `strict`.
- **Typed client**: strict TypeScript, `vue-tsc` and vitest in the gate.
- **Eyes**: Playwright and `bin/shot.mjs` screenshot any page as any user through a
  dev-only login route; a replatform compares each screen with the source's.
- **Instructions**: a hand-written `CLAUDE.md` with the product glossary, and a hook that
  names the skill to load when an edit touches an Ash resource or a Vue file.

## Install

```text
/plugin marketplace add Egorrko/ash-skills
/plugin install ash-skills@ash-skills
```

`/new-ash-project` also needs the `grilling` skill:
`/plugin install mattpocock-skills@claude-plugins-official`.

Without the plugin system, copy the three directories under `skills/` into
`~/.claude/skills/`.

Toolchain: Elixir, Node, git, PostgreSQL (a container is fine), Docker for the release
checks.

## Run

Both analysis skills write `PRODUCT_ANALYSIS.md` one level above where they run, and
the target goes beside it, so give them a workspace directory:

```bash
mkdir ~/work/myapp && cd ~/work/myapp
git clone <source-url> source && cd source && claude
```

```text
/ash-skills:replatform-to-ash myapp
/ash-skills:ash-bootstrap
```

For a new product, run `claude` in the empty workspace and start with
`/ash-skills:new-ash-project myapp`.

The bootstrap stops after the handoff. Start a new session in the target, so its
`CLAUDE.md` and skills load, and run `/next-slice` once per slice:

```bash
cd ~/work/myapp/myapp && claude
```

Every skill keeps its progress in the analysis, so an interrupted session resumes where it
stopped.

## Layout

- `skills/ash-bootstrap/references/`: the stack policy, the Ash feature catalog with the
  installer grammar, known installer defects with the versions they were seen on, and a
  runtime outside containers.
- `skills/ash-bootstrap/templates/`: the pipeline's contracts (the analysis, the handoff,
  the `next-slice` skill), the target's `CLAUDE.md`, hook and screenshot script, deploy files.

The installer defects list is kept current by the bootstrap itself: at the end of a run it
proposes the entries that reproduced, stopped reproducing, or are new.

## License

MIT
