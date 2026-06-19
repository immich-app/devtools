import { assertEquals } from "@std/assert";
import { verifySignature } from "../src/index.ts";

const TIMESTAMP = "1706609916240";

// Mirror Outline's signing: HMAC-SHA256 over `${timestamp}.${body}`, emitted as
// `t=<timestamp>,s=<hex>`.
async function sign(
  body: string,
  secret: string,
  timestamp = TIMESTAMP,
): Promise<string> {
  const enc = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw",
    enc.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign(
    "HMAC",
    key,
    enc.encode(`${timestamp}.${body}`),
  );
  const hex = Array.from(new Uint8Array(sig))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
  return `t=${timestamp},s=${hex}`;
}

Deno.test("verifySignature: valid", async () => {
  const body = '{"event":"users.signin"}', secret = "shh";
  assertEquals(
    await verifySignature(body, await sign(body, secret), secret),
    true,
  );
});

Deno.test("verifySignature: tampered body -> false", async () => {
  const secret = "shh";
  const good = await sign('{"event":"users.signin"}', secret);
  assertEquals(
    await verifySignature('{"event":"documents.update"}', good, secret),
    false,
  );
});

Deno.test("verifySignature: tampered timestamp -> false", async () => {
  const body = '{"event":"users.signin"}', secret = "shh";
  const good = await sign(body, secret);
  const tampered = good.replace(`t=${TIMESTAMP}`, "t=1799999999999");
  assertEquals(await verifySignature(body, tampered, secret), false);
});

Deno.test("verifySignature: wrong secret -> false", async () => {
  const body = "x";
  assertEquals(await verifySignature(body, await sign(body, "a"), "b"), false);
});

Deno.test("verifySignature: missing/legacy header -> false", async () => {
  assertEquals(await verifySignature("x", "", "shh"), false);
  assertEquals(await verifySignature("x", "sha256=abc", "shh"), false);
});
