import { test } from "node:test";
import assert from "node:assert/strict";
import {
  timingSafeEqual,
  splitName,
  mapRoles,
  mapSamlRoles,
  verifySignature,
} from "../src/index.js";

// --- timingSafeEqual ---

test("timingSafeEqual: equal / different / different length", () => {
  assert.equal(timingSafeEqual("abc", "abc"), true);
  assert.equal(timingSafeEqual("abc", "abd"), false);
  assert.equal(timingSafeEqual("abc", "ab"), false);
});

// --- splitName ---

test("splitName: first + last", () => {
  assert.deepEqual(splitName("zackpollard", "Zack Pollard"), { firstName: "Zack", lastName: "Pollard" });
});

test("splitName: single-word name -> space family name", () => {
  assert.deepEqual(splitName("login", "Madonna"), { firstName: "Madonna", lastName: " " });
});

test("splitName: no name -> login + space", () => {
  assert.deepEqual(splitName("login", null), { firstName: "login", lastName: " " });
});

test("splitName: multi-word family name", () => {
  assert.deepEqual(splitName("l", "Anne Marie Smith"), { firstName: "Anne", lastName: "Marie Smith" });
});

// --- mapRoles ---

const URN = "urn:zitadel:iam:org:project:123:roles";

test("mapRoles: single grant -> role claim", () => {
  const body = { userinfo: { [URN]: {} }, user_grants: [{ project_id: "123", roles: ["Leadership"] }] };
  assert.deepEqual(mapRoles(body), { append_claims: [{ key: "role", value: "Leadership" }] });
});

test("mapRoles: no project-roles claim -> {}", () => {
  assert.deepEqual(mapRoles({ userinfo: {}, user_grants: [{ project_id: "123", roles: ["X"] }] }), {});
});

test("mapRoles: grant for a different project is ignored", () => {
  const body = { userinfo: { [URN]: {} }, user_grants: [{ project_id: "999", roles: ["Other"] }] };
  assert.deepEqual(mapRoles(body), {});
});

test("mapRoles: multiple grants -> roles array (v1 nested shape)", () => {
  const body = {
    userinfo: { [URN]: {} },
    user_grants: [{ project_id: "123", roles: ["A"] }, { project_id: "123", roles: ["B"] }],
  };
  assert.deepEqual(mapRoles(body), { append_claims: [{ key: "roles", value: [["A"], ["B"]] }] });
});

// --- mapSamlRoles (grants fetched from the management API) ---

function withFetch(fn, run) {
  const orig = globalThis.fetch;
  globalThis.fetch = fn;
  return Promise.resolve(run()).finally(() => { globalThis.fetch = orig; });
}

const ENV = { ZITADEL_DOMAIN: "auth.example.org", ZITADEL_TOKEN: "pat" };

test("mapSamlRoles: dedupes roleKeys into a Roles attribute", () =>
  withFetch(
    async () => new Response(JSON.stringify({ result: [{ roleKeys: ["ADMIN", "X"] }, { roleKeys: ["X"] }] }), { status: 200 }),
    async () => {
      const out = await mapSamlRoles({ user: { id: "1" } }, ENV);
      assert.equal(out.append_attribute[0].name, "Roles");
      assert.deepEqual(out.append_attribute[0].value, ["ADMIN", "X"]);
    },
  ));

test("mapSamlRoles: no user id -> {}", async () => {
  assert.deepEqual(await mapSamlRoles({}, ENV), {});
});

test("mapSamlRoles: no grants -> {}", () =>
  withFetch(
    async () => new Response(JSON.stringify({ result: [] }), { status: 200 }),
    async () => assert.deepEqual(await mapSamlRoles({ user: { id: "1" } }, ENV), {}),
  ));

test("mapSamlRoles: API failure -> {} (no Roles, never throws)", () =>
  withFetch(
    async () => new Response("forbidden", { status: 403 }),
    async () => assert.deepEqual(await mapSamlRoles({ user: { id: "1" } }, ENV), {}),
  ));

// --- verifySignature ---

async function sign(body, key, ts) {
  const enc = new TextEncoder();
  const k = await crypto.subtle.importKey("raw", enc.encode(key), { name: "HMAC", hash: "SHA-256" }, false, ["sign"]);
  const sig = await crypto.subtle.sign("HMAC", k, enc.encode(`${ts}.${body}`));
  return Array.from(new Uint8Array(sig)).map((b) => b.toString(16).padStart(2, "0")).join("");
}

const nowSec = () => Math.floor(Date.now() / 1000);

test("verifySignature: valid fresh signature", async () => {
  const body = '{"a":1}', key = "secret", ts = String(nowSec());
  assert.equal(await verifySignature(`t=${ts},v1=${await sign(body, key, ts)}`, body, key), true);
});

test("verifySignature: tampered body -> false", async () => {
  const key = "secret", ts = String(nowSec());
  const hex = await sign('{"a":1}', key, ts);
  assert.equal(await verifySignature(`t=${ts},v1=${hex}`, '{"a":2}', key), false);
});

test("verifySignature: stale timestamp -> false", async () => {
  const body = "x", key = "secret", ts = String(nowSec() - 10000);
  assert.equal(await verifySignature(`t=${ts},v1=${await sign(body, key, ts)}`, body, key), false);
});

test("verifySignature: wrong key -> false", async () => {
  const body = "x", ts = String(nowSec());
  assert.equal(await verifySignature(`t=${ts},v1=${await sign(body, "secret", ts)}`, body, "other"), false);
});

test("verifySignature: missing v1 part -> false", async () => {
  assert.equal(await verifySignature(`t=${nowSec()}`, "x", "secret"), false);
});
