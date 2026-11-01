# `mix usage_rules.sync` reads its targets from the `usage_rules` key of the mix
# project. Add `usage_rules: usage_rules()` to `project/0` and this function to
# mix.exs, then run `mix usage_rules.sync --yes`.
#
# Skills only, no `file:`: CLAUDE.md is written by hand (templates/claude/CLAUDE.md),
# and a sync with `file:` would write the generic rules back into a rules file.
defp usage_rules do
  [
    skills: [
      location: ".claude/skills",
      build: [
        "ash-framework": [
          description:
            "Use this skill working with Ash Framework or any of its extensions. Always consult this when making any domain, resource, action, policy or migration change.",
          usage_rules: [:ash, ~r/^ash_/]
        ],
        "phoenix-framework": [
          description:
            "Use this skill working with Phoenix Framework: router, controllers, LiveView, components, Vite assets.",
          usage_rules: [:phoenix, ~r/^phoenix_/]
        ],
        "live-vue": [
          description:
            "Use this skill when working with LiveVue: Vue components rendered from LiveView, v-component, props, events, useLiveForm, uploads, LiveVue tests.",
          usage_rules: [:live_vue, ~r/^live_vue/]
        ]
      ]
    ]
  ]
end
