# Known installer defects

Hand-maintained. Defects of the stack itself, observed while bootstrapping it,
with the workaround that resolved each one. A defect of one product's extra
dependency belongs in that product's handoff, not here.

Every entry names the versions it was observed against. Confirm the defect
still reproduces before applying its workaround; delete the entry once upstream
fixes it.

Last full run: 2026-11-01 against phoenix_vite 0.6.1, live_vue 1.2.3,
Phoenix 1.8.16, usage_rules 1.3.1, igniter_new 0.5.35, typescript 6.0.3.
Every entry below reproduced on that run unless it says otherwise. Not re-tried
on it: shadcn-vue's init, usage_rules.sync without a TTY, the `--no-tailwind`
stylesheet.

## phoenix_vite points its npm profile at config/

**Symptom.** `config/config.exs` gets `assets: [args: [], cd: __DIR__]`, which is
`config/`. LiveVue puts `package.json` at the project root and resolves
`live_vue`, `phoenix` and `phoenix_vite` through `file:./deps/*`. It surfaces only
in the Docker build, because the LiveVue installer runs `npm install` itself.

**Workaround.** `cd: Path.expand("..", __DIR__)`.

## phoenix_vite makes MIX_ENV=prod mix unusable before the first asset build

**Symptom.** `MIX_ENV=prod mix assets.build` fails with `could not read file
".../priv/static/.vite/manifest.json"` from `PhoenixVite.cache_static_manifest_latest/1`,
placed at the top level of `config/runtime.exs`. mix evaluates `runtime.exs` for
every task, so the task meant to create the manifest cannot run without it. The
generated Dockerfile copies `runtime.exs` after `mix assets.deploy`, so the image
build hides it; it bites locally and in any other pipeline.

**Workaround.** Wrap the call in `try/rescue File.Error -> %{}`.

## mix test fails before the first asset build

**Symptom.** On a fresh project `PageControllerTest` fails with
`(File.Error) could not read file "_build/test/lib/<app>/priv/static/.vite/manifest.json"`.
The root layout renders `PhoenixVite.Components.assets`, which reads the manifest
when no vite watcher runs.

**Workaround.** `mix assets.build` before `mix test`; the manifest reaches
`_build` through the `priv` symlink. CI runs `mix assets.setup && mix assets.build`
before tests.

## The generated Dockerfile assumes esbuild

**Symptom.** `mix phx.gen.release --docker` produces a builder stage without Node,
which cannot build a Vite frontend.

**Workaround.** Add `nodejs` and `npm` to the builder stage, and move
`COPY package.json package-lock.json components.json tsconfig.json ./` before
`mix assets.setup` so npm runs at the project root after deps are fetched.

## .dockerignore misses the root node_modules

**Symptom.** Only `/assets/node_modules/` is excluded. The root `node_modules`
goes into the build context, hundreds of megabytes, and shadows the container's
own install. Local build output in `priv/static/.vite` and `priv/static/server.mjs`
travels the same way.

**Workaround.** Exclude the root `node_modules`, `priv/static/.vite` and
`priv/static/server.mjs`.

## Generated landing page and test outlive their content

**Symptom.** After the LiveVue installer rewrites the landing page, two leftovers
remain: a `~p"/dev/vue_demo"` verified route that exists only under `:dev_routes`,
failing `MIX_ENV=prod mix compile --warnings-as-errors`, and a page controller test
asserting on the default Phoenix copy that LiveVue overwrote.

**Workaround.** Make the dev link conditional with a plain href; point the test at
content that exists.

## shadcn-vue's init refuses to run in a Phoenix project

**Symptom.** `npx shadcn-vue@latest init` stops at "Verifying framework": *We could not
detect a supported framework*. It looks for a Vite/Nuxt/Astro/Laravel project at the
working directory; LiveVue puts `package.json` at the project root and
`vite.config.mjs` under `assets/`.

**Workaround.** The manual installation from `templates/shadcn/`, as step B2 of the
skill describes. After it, `npx shadcn-vue@latest add <component> --yes` writes into
`assets/components/ui/`.

## mix usage_rules.sync crashes on its own prompt without a TTY

Observed 2026-08-02 against usage_rules 1.2.7, igniter 0.8.3; not re-tried since
every run passes `--yes`.

**Symptom.** `mix usage_rules.sync` reaches "How would you like to proceed?" and raises
`FunctionClauseError` in `String.trim/1` given `:eof`.

**Workaround.** `mix usage_rules.sync --yes`.

## phx.new --no-tailwind links a stylesheet that git ignores

Observed 2026-10-12 against phx_new 1.8.14, on the LiveView-only path (UI layer
replaced in §12 Deviations).

**Symptom.** The root layout links `/assets/default.css`, a ~2600-line
stylesheet phx.new writes into `priv/static/assets/`, which the generated
`.gitignore` excludes. The project looks styled locally; a fresh clone or a
release built from one serves a 404 for it.

**Workaround.** Write the base stylesheet as `assets/css/app.css`, add
`css/app.css` to the esbuild entry points with `--outdir=../priv/static/assets`,
and drop the `default.css` link from `root.html.heex`.

**Verify.** `git clone` the target, `mix assets.build`, and `/assets/css/app.css`
answers 200 with no `default.css` request in the page.

## LiveVue's vite alias "@" is a bare "."

Observed 2026-11-01 against live_vue 1.2.3, phoenix_vite 0.6.1, vite 8.3.5.

**Symptom.** The LiveVue installer writes `resolve.alias: {"@": "."}` to
`assets/vite.config.mjs`. A bare `.` resolves relative to the importing file, so
`import { Button } from "@/components/ui/button"` in a Vue component fails
`MIX_ENV=prod mix assets.build` with `UNLOADABLE_DEPENDENCY … Is a directory`.

**Workaround.** `import { fileURLToPath } from "node:url"` and
`"@": fileURLToPath(new URL(".", import.meta.url))`.

**Verify.** A Vue component importing `@/components/ui/button`, then
`MIX_ENV=prod mix assets.build`.

## LiveVue's tsconfig.json fails vue-tsc under TypeScript 6

Observed 2026-11-01 against live_vue 1.2.3, typescript 6.0.3, vue-tsc 3.3.14.

**Symptom.** `npx vue-tsc --noEmit` fails with TS5101 (`baseUrl` deprecated).
With `baseUrl` removed it fails in `deps/live_vue/assets/*.ts`: `lib` ES2015
lacks `Object.entries` and `PromiseSettledResult`, and `server.ts` has no Node
types.

**Workaround.** Drop `baseUrl`; make `paths` relative (`"@/*": ["./assets/*"]`,
`"*": ["./deps/*", "./node_modules/*"]`); `target` ES2022, `lib`
`["ES2022", "DOM", "DOM.Iterable"]`; `npm i -D @types/node` and
`"types": ["vite/client", "node"]`.

**Verify.** `npx vue-tsc --noEmit` exits 0.

## Fixed upstream

- phoenix_vite 0.5.0 crashed the LiveVue installer in `has_tailwind?/1`
  (`%Rewrite.Error{reason: :nosource}`), silently dropping the Tailwind plugin from
  `vite.config.mjs`. Not reproduced on 0.6.0. If it returns, the check is: the
  plugin is present and `css/app.css` is in the rollup input.
