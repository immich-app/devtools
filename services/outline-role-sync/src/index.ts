// Cloudflare Worker that syncs ZITADEL project roles onto Outline groups.
// Triggered by Outline's `users.signin` webhook: it looks up the user's grants
// for the Outline project in ZITADEL and reconciles their Outline group
// membership + admin role. Replaces the in-cluster deno service.
import { OutlineClient } from "./outline.ts";
import { ZitadelClient } from "./zitadel.ts";

export interface Env {
  OUTLINE_BASE_URL: string;
  OUTLINE_API_TOKEN: string;
  OUTLINE_WEBHOOK_SECRET: string;
  ZITADEL_BASE_URL: string;
  ZITADEL_SERVICE_ACCOUNT_TOKEN: string;
  ZITADEL_OUTLINE_PROJECT_ID: string;
  // Comma-separated Outline project role keys; these are the Outline groups the
  // worker manages (one group per zitadel role on the project).
  ZITADEL_OUTLINE_PROJECT_ROLES: string;
}

// Minimal shape of the Workers execution context (for ctx.waitUntil).
interface ExecutionContext {
  waitUntil(promise: Promise<unknown>): void;
  passThroughOnException(): void;
}

interface WebhookPayload {
  event: string;
  // Outline sends payload.id (the affected model's id) plus a presented model;
  // for users.signin both carry the signing-in user's id.
  payload: { id: string; model?: { id?: string; email?: string } };
}

export default {
  async fetch(
    req: Request,
    env: Env,
    ctx: ExecutionContext,
  ): Promise<Response> {
    const url = new URL(req.url);

    if (url.pathname === "/health") {
      return new Response("OK");
    }
    if (url.pathname === "/webhook" && req.method === "POST") {
      return await handleWebhook(req, env, ctx);
    }
    return new Response("Not Found", { status: 404 });
  },
};

async function handleWebhook(
  req: Request,
  env: Env,
  ctx: ExecutionContext,
): Promise<Response> {
  const body = await req.text();
  const signature = req.headers.get("outline-signature") ?? "";

  if (!(await verifySignature(body, signature, env.OUTLINE_WEBHOOK_SECRET))) {
    console.error("invalid webhook signature");
    return new Response("Invalid signature", { status: 401 });
  }

  const webhook = JSON.parse(body) as WebhookPayload;
  if (webhook.event !== "users.signin") {
    return new Response("OK");
  }

  const outlineUserId = webhook.payload.model?.id ?? webhook.payload.id;
  if (!outlineUserId) {
    console.error("users.signin webhook missing a user id");
    return new Response("OK");
  }
  console.log(`received users.signin webhook for user ${outlineUserId}`);

  // Reconcile after responding so Outline's webhook delivery isn't blocked.
  ctx.waitUntil(
    syncUserRoles(outlineUserId, env).catch((err) =>
      console.error(`failed to sync roles for user ${outlineUserId}:`, err)
    ),
  );

  return new Response("OK");
}

export async function verifySignature(
  body: string,
  signatureHeader: string,
  secret: string,
): Promise<boolean> {
  // Outline signs `${timestamp}.${body}` with HMAC-SHA256 and sends the result
  // as `Outline-Signature: t=<timestamp>,s=<hex>`.
  const parts = new Map<string, string>();
  for (const part of signatureHeader.split(",")) {
    const eq = part.indexOf("=");
    if (eq === -1) continue;
    parts.set(part.slice(0, eq).trim(), part.slice(eq + 1).trim());
  }
  const timestamp = parts.get("t");
  const signature = parts.get("s");
  if (!timestamp || !signature) {
    return false;
  }

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
  const expected = Array.from(new Uint8Array(sig))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
  return expected === signature;
}

async function syncUserRoles(outlineUserId: string, env: Env): Promise<void> {
  const outline = new OutlineClient(
    env.OUTLINE_BASE_URL,
    env.OUTLINE_API_TOKEN,
  );
  const zitadel = new ZitadelClient(
    env.ZITADEL_BASE_URL,
    env.ZITADEL_SERVICE_ACCOUNT_TOKEN,
  );

  const user = await outline.getUserInfo(outlineUserId);
  console.log(`syncing roles for ${user.email} (${user.name})`);

  const zitadelUser = await zitadel.findUserByEmail(user.email);
  if (!zitadelUser) {
    console.log(`user ${user.email} not found in zitadel, skipping`);
    return;
  }

  const zitadelRoles = await zitadel.getUserGrants(
    zitadelUser.userId,
    env.ZITADEL_OUTLINE_PROJECT_ID,
  );
  console.log(
    `zitadel roles for ${user.email}: ${JSON.stringify(zitadelRoles)}`,
  );
  if (zitadelRoles.length === 0) {
    console.log("no zitadel grants for the outline project, skipping");
    return;
  }

  const allGroups = await outline.listAllGroups();
  const groupsByName = new Map(allGroups.map((g) => [g.name, g]));

  const userGroups = await outline.getUserGroups(outlineUserId);
  const currentGroupNames = new Set(userGroups.map((g) => g.name));

  // Groups the worker manages = the Outline project's zitadel role keys.
  const managedGroups = new Set(
    env.ZITADEL_OUTLINE_PROJECT_ROLES.split(",")
      .map((role) => role.trim())
      .filter((role) => role.length > 0),
  );

  const targetGroupNames = new Set(
    zitadelRoles.filter((role) => managedGroups.has(role)),
  );

  // Create any target group that doesn't exist yet.
  for (const groupName of targetGroupNames) {
    if (!groupsByName.has(groupName)) {
      console.log(`creating outline group ${groupName}`);
      groupsByName.set(groupName, await outline.createGroup(groupName));
    }
  }

  // Add the user to target groups they're not in.
  for (const groupName of targetGroupNames) {
    if (!currentGroupNames.has(groupName)) {
      console.log(`adding ${user.email} to ${groupName}`);
      await outline.addUserToGroup(
        groupsByName.get(groupName)!.id,
        outlineUserId,
      );
    }
  }

  // Remove the user from managed groups they should no longer be in.
  for (const group of userGroups) {
    if (
      managedGroups.has(group.name) && !targetGroupNames.has(group.name)
    ) {
      console.log(`removing ${user.email} from ${group.name}`);
      await outline.removeUserFromGroup(group.id, outlineUserId);
    }
  }

  // Leadership grants Outline admin.
  const shouldBeAdmin = zitadelRoles.includes("Leadership");
  if (shouldBeAdmin && user.role !== "admin") {
    console.log(`promoting ${user.email} to admin`);
    await outline.updateUserRole(outlineUserId, "admin");
  } else if (!shouldBeAdmin && user.role === "admin") {
    console.log(`demoting ${user.email} to member`);
    await outline.updateUserRole(outlineUserId, "member");
  }

  console.log(`role sync complete for ${user.email}`);
}
