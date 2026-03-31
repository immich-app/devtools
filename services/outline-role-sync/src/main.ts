import { OutlineClient } from "./outline.ts";
import { ZitadelClient } from "./zitadel.ts";

const MANAGED_GROUPS = ["Leadership", "Team", "Contributor", "Support Crew"];

function requireEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value;
}

const config = {
  outlineBaseUrl: requireEnv("OUTLINE_BASE_URL"),
  outlineApiToken: requireEnv("OUTLINE_API_TOKEN"),
  outlineWebhookSecret: requireEnv("OUTLINE_WEBHOOK_SECRET"),
  zitadelBaseUrl: requireEnv("ZITADEL_BASE_URL"),
  zitadelToken: requireEnv("ZITADEL_SERVICE_ACCOUNT_TOKEN"),
  zitadelOutlineProjectId: requireEnv("ZITADEL_OUTLINE_PROJECT_ID"),
  port: parseInt(Deno.env.get("PORT") ?? "8080"),
};

const outline = new OutlineClient(config.outlineBaseUrl, config.outlineApiToken);
const zitadel = new ZitadelClient(config.zitadelBaseUrl, config.zitadelToken);

async function verifySignature(body: string, signature: string): Promise<boolean> {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(config.outlineWebhookSecret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(body));
  const expected = Array.from(new Uint8Array(sig))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
  return `sha256=${expected}` === signature;
}

interface WebhookPayload {
  event: string;
  payload: {
    id: string;
    model: {
      id: string;
      email?: string;
    };
  };
}

async function syncUserRoles(outlineUserId: string): Promise<void> {
  const user = await outline.getUserInfo(outlineUserId);
  console.log(`Syncing roles for user: ${user.email} (${user.name})`);

  const zitadelUser = await zitadel.findUserByEmail(user.email);
  if (!zitadelUser) {
    console.log(`User ${user.email} not found in Zitadel, skipping role sync`);
    return;
  }

  const zitadelRoles = await zitadel.getUserGrants(
    zitadelUser.userId,
    config.zitadelOutlineProjectId,
  );
  console.log(`Zitadel roles for ${user.email}: ${JSON.stringify(zitadelRoles)}`);

  if (zitadelRoles.length === 0) {
    console.log(`No Zitadel grants for Outline project, skipping`);
    return;
  }

  // Sync Outline groups
  const allGroups = await outline.listAllGroups();
  const groupsByName = new Map(allGroups.map((g) => [g.name, g]));

  const userGroups = await outline.getUserGroups(outlineUserId);
  const currentGroupNames = new Set(userGroups.map((g) => g.name));

  const targetGroupNames = new Set(
    zitadelRoles.filter((role) => MANAGED_GROUPS.includes(role)),
  );

  // Create missing groups
  for (const groupName of targetGroupNames) {
    if (!groupsByName.has(groupName)) {
      console.log(`Creating Outline group: ${groupName}`);
      const newGroup = await outline.createGroup(groupName);
      groupsByName.set(groupName, newGroup);
    }
  }

  // Add user to groups they should be in
  for (const groupName of targetGroupNames) {
    if (!currentGroupNames.has(groupName)) {
      const group = groupsByName.get(groupName)!;
      console.log(`Adding ${user.email} to group: ${groupName}`);
      await outline.addUserToGroup(group.id, outlineUserId);
    }
  }

  // Remove user from managed groups they shouldn't be in
  for (const group of userGroups) {
    if (MANAGED_GROUPS.includes(group.name) && !targetGroupNames.has(group.name)) {
      console.log(`Removing ${user.email} from group: ${group.name}`);
      await outline.removeUserFromGroup(group.id, outlineUserId);
    }
  }

  // Sync admin role
  const shouldBeAdmin = zitadelRoles.includes("Leadership");
  if (shouldBeAdmin && user.role !== "admin") {
    console.log(`Promoting ${user.email} to admin`);
    await outline.updateUserRole(outlineUserId, "admin");
  } else if (!shouldBeAdmin && user.role === "admin") {
    console.log(`Demoting ${user.email} to member`);
    await outline.updateUserRole(outlineUserId, "member");
  }

  console.log(`Role sync complete for ${user.email}`);
}

async function handleWebhook(request: Request): Promise<Response> {
  const body = await request.text();
  const signature = request.headers.get("outline-signature") ?? "";

  if (!await verifySignature(body, signature)) {
    console.error("Invalid webhook signature");
    return new Response("Invalid signature", { status: 401 });
  }

  const webhook: WebhookPayload = JSON.parse(body);

  if (webhook.event !== "users.signin") {
    return new Response("OK", { status: 200 });
  }

  const outlineUserId = webhook.payload.model.id;
  console.log(`Received users.signin webhook for user: ${outlineUserId}`);

  // Process async so the webhook response isn't delayed
  syncUserRoles(outlineUserId).catch((err) => {
    console.error(`Failed to sync roles for user ${outlineUserId}:`, err);
  });

  return new Response("OK", { status: 200 });
}

function handleRequest(request: Request): Response | Promise<Response> {
  const url = new URL(request.url);

  if (url.pathname === "/health") {
    return new Response("OK", { status: 200 });
  }

  if (url.pathname === "/webhook" && request.method === "POST") {
    return handleWebhook(request);
  }

  return new Response("Not Found", { status: 404 });
}

console.log(`Starting outline-role-sync on port ${config.port}`);
Deno.serve({ port: config.port }, handleRequest);
