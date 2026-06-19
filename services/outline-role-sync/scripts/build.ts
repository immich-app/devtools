// Bundles the TypeScript worker (src/index.ts + its imports) into a single JS
// module for terraform's content_base64 — Cloudflare runs JS. Invoked by the
// data.external in terraform, so it must print ONLY a JSON object with the JS
// string on stdout (deno's own download/progress noise goes to stderr).
import { bundle } from "@deno/emit";

const entry = new URL("../src/index.ts", import.meta.url);
const result = await bundle(entry);

if (!result.code) {
  console.error("bundle produced no output");
  Deno.exit(1);
}

console.log(JSON.stringify({ js: result.code }));
