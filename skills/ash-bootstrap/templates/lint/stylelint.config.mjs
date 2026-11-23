// Stylelint: CSS errors nothing else sees (unknown properties and units, invalid hex,
// duplicate properties and selectors, empty blocks). Errors only, no style rules.
export default {
  extends: ["stylelint-config-recommended"],
  ignoreFiles: ["assets/vendor/**", "assets/node_modules/**"],
  overrides: [{ files: ["**/*.vue"], customSyntax: "postcss-html" }],
  rules: {
    // Tailwind v4 directives.
    "at-rule-no-unknown": [true, { ignoreAtRules: ["theme", "custom-variant", "utility", "plugin", "source", "variant", "reference", "config"] }],
    "function-no-unknown": [true, { ignoreFunctions: ["theme", "--alpha", "--spacing"] }],
    // Classes go in the template; CSS is plain properties.
    "at-rule-disallowed-list": [["apply"], { message: "Put the classes in the template; write CSS as plain properties." }],
    "selector-pseudo-class-no-unknown": [true, { ignorePseudoClasses: ["deep", "global", "slotted"] }],
    // Fires on :hover:not(:disabled) before :disabled in separate rules, an order
    // that is deliberate.
    "no-descending-specificity": null,
    // The shadcn-vue theme is appended to app.css as a second :root block.
    "no-duplicate-selectors": null,
  },
}
