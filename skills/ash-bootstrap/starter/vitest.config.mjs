import { fileURLToPath } from "node:url";
import { defineConfig } from "vitest/config";

export default defineConfig({
  resolve: {
    alias: { "@": fileURLToPath(new URL("./assets", import.meta.url)) },
  },
  test: {
    include: ["assets/**/*.test.ts"],
    environment: "jsdom",
  },
});
