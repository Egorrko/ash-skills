<!-- Template: /ash-bootstrap fills the <...> fields from the analysis. Keep it short:
     every line is read on every turn. Detail goes to docs/ behind a pointer. -->
<Product> — <one line from analysis §1>. Phoenix + Ash + LiveVue: every screen is a Vue
component in `assets/vue` hosted by a LiveView.

## Glossary

<From analysis §1 Glossary: each term the owner uses, what it is in the product, and the
module, route, or component it lives in. Synonyms point at one term. A term the owner
stopped using is listed with the one that replaced it.>

## Done means green

`mix precommit` is the gate; its checks are the alias in `mix.exs`. Run it once at the
end of a change and fix everything red in it. While working, run only what the change
touches: `mix test <files>`, `npx vitest run <file>`, `npm run lint:all`.

- `live_vue_contract` checks props (`defineProps<T>()`) and events (`useLiveEvents<T>()`)
  between LiveView and Vue: a compile error or a failing test names the component and the
  key. Fix the side that is wrong; `assets/vue/contract.json` is generated and committed.
  Every `pushEvent` goes through `useLiveEvents`.
- Product code reaches the database through Ash actions; `Repo` is called only in the
  files `.credo.exs` lists with a reason.
- Each Ash domain declares `use Boundary` with the domains it calls. A new dependency
  goes into that list on purpose; a cycle means the behavior belongs elsewhere.
- Client logic that is more than markup goes into a `.ts` module with a vitest test.

## Look at the screen

A visual change is checked by its screenshot: `node bin/shot.mjs <path> out.png`, signed
in: `--as <name>` (dev route `/dev/login/:name`), phone: `--size 390x844`. Read the image
and the console errors the script prints. Clicks are a separate script beside it.
A copy of this repository runs its own server with `PORT=4011 VITE_PORT=5183 mix phx.server`
and shoots with `--base http://localhost:4011`.

## Ash

Migrations are generated: `mix ash.codegen <name>` after a resource change, never written
by hand except for data migrations. Docs: `mix usage_rules.docs Module.fun`,
`mix usage_rules.search_docs "query" -p package`.

## Docs

- `docs/PRODUCT_ANALYSIS.md`: what the product must do; the slices and what is done.
- `docs/BOOTSTRAP_HANDOFF.md`: how the project was created, open questions.
<Source product, for a replatform: `<SOURCE_PATH>` is the authority on existing behavior,
 `docs/notes/screens/` holds its screenshots: a guide to content and states, not a pixel
 target.>
