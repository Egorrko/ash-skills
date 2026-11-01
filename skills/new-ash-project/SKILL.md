---
name: new-ash-project
description: Interview me about a new product and write the PRODUCT_ANALYSIS.md that /ash-bootstrap builds the Ash project from.
argument-hint: "[app-name]"
disable-model-invocation: true
---

# Design a new product for the Ash stack

Run from the workspace directory where the project will live. The output is `./PRODUCT_ANALYSIS.md`.

Call the Skill tool with "grilling". The design tree is the section order of `${CLAUDE_SKILL_DIR}/../ash-bootstrap/templates/PRODUCT_ANALYSIS.md`: purpose, actors, scenarios, domain model, business rules, authentication, background work, integrations, frontend, target architecture with its runtime and deployment, first slice. The first round opens with the application name (`$ARGUMENTS` when given, normalized to lowercase snake_case) and section 1; each later section's questions enter the frontier once the sections it depends on are settled.

Recommended answers follow `${CLAUDE_SKILL_DIR}/../ash-bootstrap/references/STACK_POLICY.md`; the stack is settled, the product is what the interview designs. Where the product contradicts a policy default (a runtime that cannot be a container, a client that cannot run the frontend), the contradiction is a frontier question with the policy as the recommended answer, and the decision lands in §12 Deviations with its reason and evidence. A constraint without evidence yet (an old device nobody has tried) becomes a check for the user to run, and the policy default stands until it comes back.

## Write as the frontier settles

Create `./PRODUCT_ANALYSIS.md` from the template before the first round, with the metadata filled: origin `new product`, target application, target path `./<app>`. Write a section the moment its subtree of the frontier is settled, append ` — done` to its heading, and tick the progress items as their sections complete. The file grows during the interview; a decision lands in it in the round it is made. Fact-finding that outgrows a section goes to `notes/` beside it.

Section 10 reads `Not applicable: new product.` Sections 11 and 14 belong to the bootstrap.

## Done

The frontier is empty, every applicable section is written, analysis items A1–A4 are ticked, and the user has confirmed the shared understanding. Then tell the user to run `/ash-bootstrap`, here or in a fresh session.
