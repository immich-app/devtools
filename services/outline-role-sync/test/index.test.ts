import { assertEquals } from "@std/assert";
import { verifySignature } from "../src/index.ts";

async function sign(body: string, secret: string): Promise<string> {
  const enc = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw",
    enc.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign("HMAC", key, enc.encode(body));
  return "sha256=" +
    Array.from(new Uint8Array(sig)).map((b) => b.toString(16).padStart(2, "0"))
      .join("");
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

Deno.test("verifySignature: wrong secret -> false", async () => {
  const body = "x";
  assertEquals(await verifySignature(body, await sign(body, "a"), "b"), false);
});

Deno.test("verifySignature: missing signature -> false", async () => {
  assertEquals(await verifySignature("x", "", "shh"), false);
});
