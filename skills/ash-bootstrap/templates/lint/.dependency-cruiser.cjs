// The client's module graph. Each rule names the direction imports may go.
/** @type {import("dependency-cruiser").IConfiguration} */
module.exports = {
  forbidden: [
    {
      name: "no-circular",
      severity: "error",
      comment: "A runtime import cycle: a module in it sees its neighbour half-loaded. Cycles through import type only do not count.",
      // shadcn-vue generates Component.vue <-> index.ts cycles for cva variants (badge, button)
      from: { pathNot: "^assets/components/ui/" },
      to: { circular: true, viaOnly: { dependencyTypesNot: ["type-only", "type-import", "dynamic-import"] } },
    },
    {
      name: "ui-not-to-product",
      severity: "error",
      comment: "components/ui holds generic primitives; they know nothing of the product's pages and components.",
      from: { path: "^assets/components/ui/" },
      to: { path: "^assets/vue/" },
    },
    {
      name: "no-npm-cn",
      severity: "error",
      comment: "cn comes from @/lib/utils; shadcn-vue add rewrites it to the unrelated npm package cn (INSTALLER_DEFECTS.md).",
      from: {},
      to: { path: "^cn$|(^|/)node_modules/cn/" },
    },
    {
      name: "no-test-in-app",
      severity: "error",
      comment: "Application code does not import tests or their helpers.",
      from: { path: "^assets/", pathNot: "[.]test[.]ts$" },
      to: { path: "[.]test[.]ts$" },
    },
  ],
  options: {
    doNotFollow: { path: "(^|/)(node_modules|deps)/" },
    tsConfig: { fileName: "tsconfig.json" },
    tsPreCompilationDeps: true,
    enhancedResolveOptions: { extensions: [".ts", ".js", ".mjs", ".vue", ".json"] },
    cache: { folder: "_build/depcruise-cache", strategy: "content" },
  },
}
