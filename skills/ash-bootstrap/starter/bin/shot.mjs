#!/usr/bin/env node
// Screenshot a page of the dev server, so a screen is checked by looking at it.
//
//   node bin/shot.mjs /settings out.png
//   node bin/shot.mjs /orders out.png --as alice --size 390x844
//   node bin/shot.mjs /orders out.png --base http://localhost:4001 --full
//
// --as signs in through the dev-only route /dev/login/:name first.
// The base URL: --base, else BASE, else http://localhost:$PORT (PORT from the env or .env, else 4000).
// A sequence of clicks is its own script next to this one; this one only opens the page.
import { readFileSync, existsSync } from "fs"
import { chromium } from "../node_modules/playwright/index.mjs"

const withValue = new Set(["--as", "--size", "--base", "--wait"])
const flags = {}
const positional = []
const argv = process.argv.slice(2)
for (let i = 0; i < argv.length; i++) {
  if (withValue.has(argv[i])) flags[argv[i]] = argv[++i]
  else if (argv[i].startsWith("--")) flags[argv[i]] = true
  else positional.push(argv[i])
}
const [path, out] = positional

if (!path || !out) {
  console.error("usage: node bin/shot.mjs <path> <out.png> [--as name] [--size WxH] [--base URL] [--wait ms] [--full]")
  process.exit(1)
}

function envPort() {
  if (process.env.PORT) return process.env.PORT
  if (!existsSync(".env")) return "4000"
  const line = readFileSync(".env", "utf8").split("\n").find(l => /^\s*(export\s+)?PORT=/.test(l))
  return line ? line.split("=")[1].trim().replace(/^["']|["']$/g, "") : "4000"
}

const [width, height] = (flags["--size"] ?? "1440x900").split("x").map(Number)
const base = flags["--base"] ?? process.env.BASE ?? `http://localhost:${envPort()}`
const url = flags["--as"]
  ? `${base}/dev/login/${encodeURIComponent(flags["--as"])}?return_to=${encodeURIComponent(path)}`
  : base + path

const browser = await chromium.launch()
const page = await browser.newPage({ viewport: { width, height }, deviceScaleFactor: 2 })
const errors = []
page.on("pageerror", e => errors.push(e.message))
page.on("console", m => m.type() === "error" && errors.push(m.text()))

const response = await page.goto(url, { waitUntil: "networkidle" })
// dev toolbars (Tidewave, LiveDebugger) sit over the page and catch clicks
await page.addStyleTag({ content: "#tidewave-toolbar,#live-debugger-debug-button{display:none !important}" })
await page.waitForTimeout(Number(flags["--wait"] ?? 1500))
await page.screenshot({ path: out, fullPage: flags["--full"] === true })
const finalUrl = page.url()
await browser.close()

console.log(`${out} (HTTP ${response?.status()}, ${finalUrl})`)
for (const e of errors) console.log(`console error: ${e}`)
