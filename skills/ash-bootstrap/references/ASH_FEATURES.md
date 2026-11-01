# Ash features: installer grammar and selection

Hand-maintained. Package versions are the installer's business, so none are
recorded here. Confirm the grammar against `mix help igniter.new` before running
it; Ash HQ (https://ash-hq.org) generates the same command interactively and is
the reference when they disagree.

## Installer grammar

Archives first:

```bash
mix archive.install hex igniter_new --force
mix archive.install hex phx_new --force
```

Project creation, as Ash HQ's builder emits it. `--install` takes packages in
pairs; feature arguments follow the package list:

```bash
mix igniter.new <app_name> \
  --with phx.new \
  --install ash,ash_phoenix \
  --install ash_postgres,usage_rules \
  --install <next pair> \
  <feature installer arguments> \
  --setup \
  --yes
```

Data layer: `postgres` is the phx.new default. `sqlite` adds
`--with-args "--database sqlite3"`; no relational layer adds
`--with-args "--no-ecto"`.

LiveVue has no Ash HQ feature. After `igniter.new` finishes, run its own
installer: `mix igniter.install live_vue` (check `INSTALLER_DEFECTS.md` first).

## Features

Every optional feature cites the analysis section that requires it; a feature
nobody cites stays out. "Always" rows are the stack itself.

| Key | Packages | Installer argument | Select when |
| --- | --- | --- | --- |
| `phoenix` | `ash_phoenix` | | Always. |
| `postgres` | `ash_postgres` | | Always. `sqlite` / `csv` (`ash_sqlite`, `ash_csv`) replace it only when the product genuinely has no relational server database. |
| `usage_rules` | `usage_rules` | | Always. |
| `live_vue_contract` | `live_vue_contract` (Hex) and `vue-component-meta` (npm) | manual setup | Always, with `live_vue`: the props contract of the quality harness in `STACK_POLICY.md`. |
| `live_vue` | `live_vue` | separate installer, see above | Always, unless §12 Deviations replaces the UI layer. |
| `graphql` | `ash_graphql` | | A GraphQL contract stays part of the product. A new LiveVue UI needs none. |
| `json_api` | `ash_json_api` | | An external or mobile client depends on the contract. |
| `ash_typescript` | `ash_typescript` | `--framework react` | A typed RPC client outside LiveView is genuinely wanted, which contradicts LiveView owning state. Rejected for form generation: codegen always lands an RPC client and public `typescript_rpc` config; zod schemas reflect attributes only, so action validations diverge; schemas carry no control metadata (a color and a name are both `z.string()`). |
| `password_auth` | `ash_authentication`, `ash_authentication_phoenix` | `--auth-strategy password` | The product supports it. Pick strategies from actual behavior, one argument per strategy. |
| `magic_link_auth` | same | `--auth-strategy magic_link` | Same. |
| `api_key_auth` | `ash_authentication` | `--auth-strategy api_key` | Same. |
| `oauth` | `ash_authentication`, `ash_authentication_phoenix` | manual setup | Same. Provider credentials are runtime variables; they go in the handoff. |
| `oban` | `ash_oban`, `oban_web` | | Durable, scheduled, or retried work. The default for anything that must survive a restart. |
| `state_machine` | `ash_state_machine` | | Allowed transitions are business rules the product enforces. A status column is not a state machine. |
| `ash_events` | `ash_events` | | A persisted action log with replay is part of the target architecture. |
| `archival` | `ash_archival` | | Records that must never be physically destroyed. |
| `paper_trail` | `ash_paper_trail` | | A real audit requirement: who changed what, when. |
| `cloak` | `cloak`, `ash_cloak` | | Attributes encrypted at rest. Key management becomes a runtime variable; record it in the handoff. |
| `money` | `ash_money` | | The product handles money amounts. |
| `double_entry` | `ash_double_entry` (requires `money`) | | The product keeps accounts and ledgers. |
| `ash_ai` | `ash_ai` | | Genuinely generative behavior. Deterministic rules stay in deterministic Elixir. |
| `tidewave` | `tidewave` | | Development tooling; select when the user wants it. |
| `admin` | `ash_admin` | | An internal operator interface. Never a substitute for product screens. |
| `live_debugger` | `live_debugger` | | Development only. |
| `cinder`, `mishka` | | | Out. Both render components in LiveView templates and duplicate the Vue component layer in `STACK_POLICY.md`. |
| `appsignal`, `opentelemetry` | `ash_appsignal`, `opentelemetry_ash` | manual setup, no installer | Observability the product already had or the user asks for. |

## Packages outside this list

Search Hex and the web. Before selecting one, verify:

1. the analysis names a concrete behavior that needs it;
2. current Ash compatibility, release date, and repository activity;
3. it ships `usage-rules.md` or a working Igniter installer;
4. built-in Ash, Phoenix, or OTP functionality is not simpler.
