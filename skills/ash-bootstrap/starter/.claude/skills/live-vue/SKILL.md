---
name: live-vue
description: "Use this skill when working with LiveVue: Vue components rendered from LiveView, v-component, props, events, useLiveForm, uploads, LiveVue tests."
metadata:
  managed-by: usage-rules
---

<!-- usage-rules-skill-start -->
## Additional References

### live_vue

- [live_vue](references/live_vue/live_vue.md)

## Searching Documentation

```sh
mix usage_rules.search_docs "search term" -p live_vue -p live_vue_contract
```

## Available Mix Tasks

- `mix live_vue.install`
- `mix compile.live_vue_contract` - Regenerates the LiveVue props contract from defineProps when its sources changed
- `mix live_vue_contract.coverage` - Merges the coverage of partitioned test runs into one report
<!-- usage-rules-skill-end -->
