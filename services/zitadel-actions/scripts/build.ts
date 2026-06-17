// Transpiles the TypeScript worker (src/index.ts) to JavaScript for terraform's
// content_base64 — Cloudflare runs JS, the source is TS. Invoked by the
// data.external in actions-v2.tf, so it must print ONLY a JSON object with the
// JS string on stdout (deno's own download/progress noise goes to stderr).
import { transpile } from "@deno/emit";

const entry = new URL("../src/index.ts", import.meta.url);
const result = await transpile(entry);
const js = result.get(entry.href);

if (!js) {
  console.error(`transpile produced no output for ${entry.href}`);
  Deno.exit(1);
}

console.log(JSON.stringify({ js }));
