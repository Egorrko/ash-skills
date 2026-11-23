// ESLint: only what oxlint and vue-tsc do not check. oxlint reads the <script> of a
// .vue file but not its template, and oxlint's type-aware rules (oxlint-tsgolint) skip
// .vue files. So this file has the template rules of eslint-plugin-vue, the
// accessibility rules a template can break, and the type-aware rules for <script> in .vue.
import vue from "eslint-plugin-vue"
import a11y from "eslint-plugin-vuejs-accessibility"
import vueParser from "vue-eslint-parser"
import tseslint from "typescript-eslint"

// The same promise and type rules .oxlintrc.types.json applies to .ts files.
const typeRules = {
  "@typescript-eslint/await-thenable": "error",
  "@typescript-eslint/no-floating-promises": "error",
  "@typescript-eslint/no-misused-promises": "error",
  "@typescript-eslint/switch-exhaustiveness-check": ["error", { considerDefaultExhaustiveForUnions: true }],
  "@typescript-eslint/no-for-in-array": "error",
  "@typescript-eslint/no-implied-eval": "error",
  "@typescript-eslint/no-base-to-string": "error",
  "@typescript-eslint/prefer-promise-reject-errors": "error",
  "@typescript-eslint/only-throw-error": "error",
  "@typescript-eslint/restrict-plus-operands": "error",
  "@typescript-eslint/no-unsafe-enum-comparison": "error",
  "@typescript-eslint/no-array-delete": "error",
  "@typescript-eslint/no-duplicate-type-constituents": "error",
  "@typescript-eslint/require-array-sort-compare": ["error", { ignoreStringArrays: true }],
  "@typescript-eslint/prefer-find": "error",
  "@typescript-eslint/no-unnecessary-template-expression": "error",
}

export default [
  { ignores: ["assets/vendor/**", "assets/node_modules/**", "assets/components/ui/**", "deps/**", "_build/**", "node_modules/**", "priv/**"] },
  {
    files: ["assets/**/*.vue"],
    plugins: { vue, "vuejs-accessibility": a11y },
    languageOptions: {
      parser: vueParser,
      parserOptions: { parser: tseslint.parser, sourceType: "module", ecmaVersion: "latest" },
    },
    linterOptions: { reportUnusedDisableDirectives: "error" },
    rules: {
      "vue/no-parsing-error": "error",
      "vue/require-explicit-emits": "error",
      "vue/no-unused-emit-declarations": "error",
      "vue/no-unused-properties": ["error", { groups: ["props"] }],
      "vuejs-accessibility/alt-text": "error",
      "vuejs-accessibility/anchor-has-content": "error",
      "vuejs-accessibility/aria-props": "error",
      "vuejs-accessibility/aria-role": "error",
      "vuejs-accessibility/heading-has-content": "error",
      "vuejs-accessibility/iframe-has-title": "error",
      "vuejs-accessibility/no-access-key": "error",
      "vuejs-accessibility/no-distracting-elements": "error",
      "vuejs-accessibility/role-has-required-aria-props": "error",
      "vuejs-accessibility/tabindex-no-positive": "error",
    },
  },
  {
    // Root components take their props from <.vue> in HEEx, which live_vue_contract
    // checks; an unread prop there is a question for the LiveView, not the component.
    files: ["assets/vue/*.vue"],
    rules: { "vue/no-unused-properties": "off" },
  },
  {
    files: ["assets/vue/**/*.vue"],
    languageOptions: {
      parser: vueParser,
      parserOptions: {
        parser: tseslint.parser,
        projectService: true,
        extraFileExtensions: [".vue"],
        tsconfigRootDir: import.meta.dirname,
        sourceType: "module",
      },
    },
    plugins: { "@typescript-eslint": tseslint.plugin },
    rules: typeRules,
  },
]
