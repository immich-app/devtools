import { assertEquals } from "@std/assert";
import {
  type Env,
  mapAccessTokenGroups,
  mapRoles,
  mapSamlRoles,
  splitName,
  verifySignature,
} from "../src/index.ts";

const ENV: Env = {
  ZITADEL_DOMAIN: "auth.example.org",
  ZITADEL_TOKEN: "pat",
  GITHUB_IDP_ID: "gh",
  GITLAB_IDP_ID: "gl",
  IDP_INTENT_SIGNING_KEY: "i",
  TOKEN_SIGNING_KEY: "t",
  // Distinct from the project 123 used in the role/roles cases below, so those
  // assert the non-NetBird path (no groups claim).
  NETBIRD_PROJECT_ID: "456",
};

// --- splitName ---

Deno.test("splitName: first + last", () => {
  assertEquals(splitName("zackpollard", "Zack Pollard"), {
    firstName: "Zack",
    lastName: "Pollard",
  });
});

Deno.test("splitName: single-word name -> space family name", () => {
  assertEquals(splitName("login", "Madonna"), {
    firstName: "Madonna",
    lastName: " ",
  });
});

Deno.test("splitName: no name -> login + space", () => {
  assertEquals(splitName("login", null), { firstName: "login", lastName: " " });
});

Deno.test("splitName: multi-word family name", () => {
  assertEquals(splitName("l", "Anne Marie Smith"), {
    firstName: "Anne",
    lastName: "Marie Smith",
  });
});

// --- mapRoles ---

const URN = "urn:zitadel:iam:org:project:123:roles";

Deno.test("mapRoles: single grant -> role claim", () => {
  const body = {
    userinfo: { [URN]: {} },
    user_grants: [{ project_id: "123", roles: ["Leadership"] }],
  };
  assertEquals(mapRoles(body, ENV), {
    append_claims: [{ key: "role", value: "Leadership" }],
  });
});

Deno.test("mapRoles: no project-roles claim -> {}", () => {
  assertEquals(
    mapRoles({
      userinfo: {},
      user_grants: [{ project_id: "123", roles: ["X"] }],
    }, ENV),
    {},
  );
});

Deno.test("mapRoles: grant for a different project is ignored", () => {
  const body = {
    userinfo: { [URN]: {} },
    user_grants: [{ project_id: "999", roles: ["Other"] }],
  };
  assertEquals(mapRoles(body, ENV), {});
});

Deno.test("mapRoles: multiple grants -> roles array (v1 nested shape)", () => {
  const body = {
    userinfo: { [URN]: {} },
    user_grants: [{ project_id: "123", roles: ["A"] }, {
      project_id: "123",
      roles: ["B"],
    }],
  };
  assertEquals(mapRoles(body, ENV), {
    append_claims: [{ key: "roles", value: [["A"], ["B"]] }],
  });
});

// --- mapRoles: NetBird project also emits a flat `groups` claim ---

const NB_URN = "urn:zitadel:iam:org:project:456:roles";

Deno.test("mapRoles: netbird project emits a flat groups claim", () => {
  const body = {
    userinfo: { [NB_URN]: {} },
    user_grants: [{ project_id: "456", roles: ["team", "futo"] }],
  };
  assertEquals(mapRoles(body, ENV), {
    append_claims: [
      { key: "groups", value: ["team", "futo"] },
      { key: "role", value: "team,futo" },
    ],
  });
});

Deno.test("mapRoles: netbird groups are deduped across grants", () => {
  const body = {
    userinfo: { [NB_URN]: {} },
    user_grants: [
      { project_id: "456", roles: ["team", "futo"] },
      { project_id: "456", roles: ["futo", "yucca"] },
    ],
  };
  assertEquals(mapRoles(body, ENV), {
    append_claims: [
      { key: "groups", value: ["team", "futo", "yucca"] },
      { key: "roles", value: [["team", "futo"], ["futo", "yucca"]] },
    ],
  });
});

// --- mapAccessTokenGroups (preaccesstoken: groups into the JWT access token) ---

Deno.test("mapAccessTokenGroups: emits deduped groups for the netbird project", () => {
  const body = {
    function: "function/preaccesstoken",
    user_grants: [
      { project_id: "456", roles: ["team", "futo"] },
      { project_id: "456", roles: ["futo", "yucca"] },
    ],
  };
  assertEquals(mapAccessTokenGroups(body, ENV), {
    append_claims: [{ key: "groups", value: ["team", "futo", "yucca"] }],
  });
});

Deno.test("mapAccessTokenGroups: ignores grants for other projects", () => {
  const body = {
    user_grants: [{ project_id: "123", roles: ["Leadership"] }],
  };
  assertEquals(mapAccessTokenGroups(body, ENV), {});
});

Deno.test("mapAccessTokenGroups: no grants -> {}", () => {
  assertEquals(mapAccessTokenGroups({ user_grants: [] }, ENV), {});
});

// --- mapSamlRoles (grants fetched from the management API) ---

async function withFetch(
  fn: typeof fetch,
  run: () => Promise<void>,
): Promise<void> {
  const orig = globalThis.fetch;
  globalThis.fetch = fn;
  try {
    await run();
  } finally {
    globalThis.fetch = orig;
  }
}

Deno.test("mapSamlRoles: dedupes roleKeys into a Roles attribute", () =>
  withFetch(
    () =>
      Promise.resolve(
        new Response(
          JSON.stringify({
            result: [{ roleKeys: ["ADMIN", "X"] }, { roleKeys: ["X"] }],
          }),
          { status: 200 },
        ),
      ),
    async () => {
      const out = await mapSamlRoles({ user: { id: "1" } }, ENV);
      assertEquals(out.append_attribute?.[0].name, "Roles");
      assertEquals(out.append_attribute?.[0].value, ["ADMIN", "X"]);
    },
  ));

Deno.test("mapSamlRoles: no user id -> {}", async () => {
  assertEquals(await mapSamlRoles({}, ENV), {});
});

Deno.test("mapSamlRoles: no grants -> {}", () =>
  withFetch(
    () =>
      Promise.resolve(
        new Response(JSON.stringify({ result: [] }), { status: 200 }),
      ),
    async () =>
      assertEquals(await mapSamlRoles({ user: { id: "1" } }, ENV), {}),
  ));

Deno.test("mapSamlRoles: API failure -> {} (no Roles, never throws)", () =>
  withFetch(
    () => Promise.resolve(new Response("forbidden", { status: 403 })),
    async () =>
      assertEquals(await mapSamlRoles({ user: { id: "1" } }, ENV), {}),
  ));

// --- verifySignature ---

async function sign(body: string, key: string, ts: string): Promise<string> {
  const enc = new TextEncoder();
  const k = await crypto.subtle.importKey(
    "raw",
    enc.encode(key),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign("HMAC", k, enc.encode(`${ts}.${body}`));
  return Array.from(new Uint8Array(sig)).map((b) =>
    b.toString(16).padStart(2, "0")
  ).join("");
}

const nowSec = () => Math.floor(Date.now() / 1000);

Deno.test("verifySignature: valid fresh signature", async () => {
  const body = '{"a":1}', key = "secret", ts = String(nowSec());
  assertEquals(
    await verifySignature(`t=${ts},v1=${await sign(body, key, ts)}`, body, key),
    true,
  );
});

Deno.test("verifySignature: tampered body -> false", async () => {
  const key = "secret", ts = String(nowSec());
  const hex = await sign('{"a":1}', key, ts);
  assertEquals(
    await verifySignature(`t=${ts},v1=${hex}`, '{"a":2}', key),
    false,
  );
});

Deno.test("verifySignature: stale timestamp -> false", async () => {
  const body = "x", key = "secret", ts = String(nowSec() - 10000);
  assertEquals(
    await verifySignature(`t=${ts},v1=${await sign(body, key, ts)}`, body, key),
    false,
  );
});

Deno.test("verifySignature: wrong key -> false", async () => {
  const body = "x", ts = String(nowSec());
  assertEquals(
    await verifySignature(
      `t=${ts},v1=${await sign(body, "secret", ts)}`,
      body,
      "other",
    ),
    false,
  );
});

Deno.test("verifySignature: missing v1 part -> false", async () => {
  assertEquals(await verifySignature(`t=${nowSec()}`, "x", "secret"), false);
});
