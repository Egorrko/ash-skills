# <Product> analysis

## Progress

Tick each item when it finishes. A resumed run continues from the first unticked
item after confirming the recorded state against the filesystem. A finished
analysis section gets ` — done` appended to its heading.

Analysis (`/replatform-to-ash` or `/new-ash-project`):

- [ ] A0. Feasibility answered, and the user's decision recorded when an answer was bad
- [ ] A1. Sections 1–10 written
- [ ] A2. Section 12 target architecture written, runtime profile decided, deviations recorded with evidence
- [ ] A3. Section 13 slices listed, the first one agreed
- [ ] A4. Section 15 open questions recorded

Bootstrap (`/ash-bootstrap`):

- [ ] B0. Toolchain checked
- [ ] B1. Dependencies selected (§11) and target created at the path below with the command in §14
- [ ] B2. UsageRules skills, `CLAUDE.md`, skill hook, component layer, `next-slice` installed
- [ ] B3. Quality harness installed, each part's check passed
- [ ] B4. Bootstrap verified, deployment artefact in place, target committed at revision: <sha>
- [ ] B5. Analysis, notes and handoff copied into the target and committed

## Metadata

- Origin: source repository `<path>` at revision `<sha>` | new product
- Target application: `<otp_app_name>`
- Target path: `<absolute path>`
- Analysis date:
- Toolchain versions and unavailable tools (bootstrap fills this):

Fact-finding that outgrows a section (protocol dumps, reverse-engineering
notes, vendor API traces) lives in `notes/` beside this file and is referenced
from the section that needs it. The bootstrap copies `notes/` into the target's
`docs/notes/`.

## Feasibility

Answered before the full analysis, each with its evidence. A new product writes
`Not applicable: new product.` and names only the owner and the maintainers.

- **Volume**: files and lines per area, screens, integrations, a first count of slices.
- **Oracle**: what shows the target behaves like the source: the owner's
  specification, the source's tests, production data compared side by side; and
  whether the agent can run it.
- **Libraries**: each capability the source takes from a library with no Elixir
  counterpart (a SQL parser, a rendering engine, a vendor SDK), with what a
  rewrite of it would take.
- **Upstream**: what the source receives from a project it follows (a fork, a
  vendor release), how often, and what stops arriving after the move.
- **People**: the owner who decides product questions, and who maintains the
  target afterwards.
- **Decision**: go, a pilot slice first (which scenario, what it measures), or stop.

## 1. Product purpose

The product, its users, and the value it provides.

### Glossary

The words the owner and the users call things by, each with what it is and where
it lives in the target (module, route, component). Synonyms point at one term.
The bootstrap carries this list into the target's `CLAUDE.md`: an agent that
hears a term finds its code without guessing.

## 2. Actors and roles

Identity, roles, ownership, and allowed operations.

## 3. User scenarios

Complete end-to-end scenarios. For a replatform each ends with its verdict
(carry, redesign with the new behavior, or drop) and the usage evidence behind it.

## 4. Domain model

For each important entity: purpose; fields and constraints; relationships;
lifecycle; invariants; source files and migrations where a source exists.

## 5. Business rules

Deterministic product rules, each with its source and test reference where a
source exists, and for a replatform its verdict and evidence, as in §3.

## 6. Authentication and authorization

Login strategies, sessions or tokens, roles, ownership, tenancy, administrative
access.

## 7. Background and scheduled work

Triggers, durability, retries, schedules, side effects, failure behavior.

## 8. External integrations

APIs, bots, email, payments, files, AI, speech, analytics, operational
dependencies.

## 9. Frontend behavior

Screens, Vue components, server-driven updates, local state, local drafts,
reconnect and offline behavior. For a source with a UI, every screen has a
reference screenshot in `notes/screens/` (see the analysis skill), named by route
and state. Clients on other devices (a phone, a tablet, a
kiosk) with their browser versions, and how each was established: a user agent
read from the device, a spike opened on it.

## 10. Data migration and compatibility

Identifiers, constraints, timestamps, enums, files, secrets, historical data,
migration risks. A new product writes `Not applicable: new product.`

## 11. Target dependencies

Filled by the bootstrap. For every optional feature from `ASH_FEATURES.md`:

### <Feature>

- Required by: §<n>, <behavior>
- Packages and installer argument:
- Configuration and migration work:

## 12. Target architecture

Proposed Ash Domains, Resources, actions, policies, calculations, jobs,
LiveViews, and LiveVue component structure.

### Deviations

Every place this product leaves `STACK_POLICY.md`, one entry each: the policy
element, its replacement, the reason, and the **evidence**. Evidence is
something observed: a spike run on the device, a user agent with a
compatibility table, a measured limit, a deployment file. A constraint nobody
has checked yet goes to §15 as an open question, with the check that would
settle it, and the policy default stands until then. `None.` is the usual
entry.

### Runtime and deployment

The runtime profile from `STACK_POLICY.md`, "Deployment": Swarm (the default),
Kubernetes on the organisation's cluster, or native, with the reason. Swarm and
Kubernetes: the registry and image name. Kubernetes: the cluster's owners and
where their conventions are written. Native: the artefact the bootstrap writes.
The database server the target needs. Each of these unknown: say so here, and it
becomes an open question.

## 13. Vertical slices

The slices in build order, each a user-visible scenario, marked done as they
land. The first is written in full for the first implementation session:
user-visible start and finish; Resources and actions; authorization; UI path;
tests and verification; scope boundary. Admin screens are slices after the
admin shell (`STACK_POLICY.md`, "Admin screens"). A request that arrives later
is added here before it is built.

## 14. Bootstrap command

Filled by the bootstrap: the exact command that created the target.

## 15. Open questions

Remaining ambiguity, each entry stating what it blocks. From the bootstrap
onwards the handoff carries this queue.
