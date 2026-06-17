// Single Cloudflare Worker hosting all ZITADEL Actions v2 handlers for the
// internal cloud instance, replacing the v1 actions.
//
// Routing (one worker, two ZITADEL targets — a target has one target_type):
//   POST /idp-intent  — REST_WEBHOOK target on RetrieveIdentityProviderIntent
//                       response. Syncs the real email + name from the external
//                       IdP onto the ZITADEL user via the management API, before
//                       the token is issued. Replaces mapGitHubOAuth /
//                       mapGitLabOAuth. (validated)
//   POST /token       — REST_CALL target on the preuserinfo / presamlresponse
//                       functions. Returns claim/attribute manipulation.
//                       Replaces mapRoles / samlMapRoles. (phase 2)
//
// Each path verifies the ZITADEL HMAC signature with that target's own signing
// key. Secrets/config are injected as Worker bindings (see Env below).

export interface Env {
  ZITADEL_DOMAIN: string;
  ZITADEL_TOKEN: string;
  GITHUB_IDP_ID: string;
  GITLAB_IDP_ID: string;
  IDP_INTENT_SIGNING_KEY: string;
  TOKEN_SIGNING_KEY: string;
}

// Manipulation returned to ZITADEL. `{}` means "no change".
export interface Manipulation {
  append_claims?: Array<{ key: string; value: unknown }>;
  append_attribute?: Array<
    { name: string; name_format: string; value: string[] }
  >;
}

type Handler = (body: unknown) => Manipulation | Promise<Manipulation>;

export default {
  async fetch(req: Request, env: Env): Promise<Response> {
    const url = new URL(req.url);

    if (req.method !== "POST") {
      return new Response("Not found", { status: 404 });
    }

    switch (url.pathname) {
      case "/idp-intent":
        return await handleVerified(
          req,
          env.IDP_INTENT_SIGNING_KEY,
          (body) => handleIdpIntent(body as IdpIntentBody, env),
        );
      case "/token":
        return await handleVerified(
          req,
          env.TOKEN_SIGNING_KEY,
          (body) => handleToken(body as TokenBody, env),
        );
      default:
        return new Response("Not found", { status: 404 });
    }
  },
};

// Verify the ZITADEL signature, parse JSON, hand off to `handler`, and turn its
// return value into a JSON 200. A thrown handler error becomes a 500 — with
// interrupt_on_error=false on the target, ZITADEL ignores it and the login
// proceeds unchanged, so a worker fault can never break authentication.
async function handleVerified(
  req: Request,
  signingKey: string,
  handler: Handler,
): Promise<Response> {
  if (!signingKey) {
    console.error("[init] missing signing key binding");
    return new Response("Missing configuration", { status: 500 });
  }
  const signature = req.headers.get("zitadel-signature");
  if (!signature) {
    return new Response("Missing signature", { status: 400 });
  }
  const rawBody = await req.text();
  if (!(await verifySignature(signature, rawBody, signingKey))) {
    return new Response("Invalid signature", { status: 400 });
  }

  let body: unknown;
  try {
    body = JSON.parse(rawBody);
  } catch {
    return new Response("Invalid JSON", { status: 400 });
  }

  try {
    const result = (await handler(body)) ?? {};
    return Response.json(result);
  } catch (e) {
    console.error("[handler] error:", e instanceof Error ? e.stack : e);
    return new Response("Internal error", { status: 500 });
  }
}

// --- /idp-intent : profile sync ------------------------------------------

interface IdpInformation {
  idpId: string;
  userName?: string;
  // deno-lint-ignore no-explicit-any -- untrusted IdP profile, shape varies
  rawInformation?: Record<string, any>;
  oauth?: { accessToken?: string };
}

interface IdpIntentBody {
  response?: { userId?: string; idpInformation?: IdpInformation };
}

async function handleIdpIntent(
  body: IdpIntentBody,
  env: Env,
): Promise<Manipulation> {
  const idp = body?.response?.idpInformation;
  const userId = body?.response?.userId;
  if (!idp || !userId) {
    console.log("[idp-intent] no idpInformation/userId — skipping");
    return {};
  }

  const raw = idp.rawInformation ?? {};
  let email: string | null = null;
  let firstName: string;
  let lastName: string;

  if (idp.idpId === env.GITHUB_IDP_ID) {
    // GitHub: primary email comes from /user/emails (profile email may be null
    // when the user keeps it private); name split mirrors the old v1 action.
    email = (await githubPrimaryEmail(idp?.oauth?.accessToken)) ?? raw.email ??
      null;
    ({ firstName, lastName } = splitName(raw.login ?? idp.userName, raw.name));
  } else if (idp.idpId === env.GITLAB_IDP_ID) {
    // GitLab is OIDC — email + name are already in the userinfo.
    email = raw.email ?? null;
    ({ firstName, lastName } = splitName(
      raw.nickname ?? raw.preferred_username ?? idp.userName,
      raw.name,
    ));
  } else {
    console.log(`[idp-intent] idpId ${idp.idpId} not handled — skipping`);
    return {};
  }

  if (!email) {
    console.log(`[idp-intent] no email resolved for user ${userId} — skipping`);
    return {};
  }

  await updateHumanUser(env, userId, email, firstName, lastName);
  // REST_WEBHOOK ignores the response body.
  return {};
}

async function githubPrimaryEmail(
  accessToken: string | undefined,
): Promise<string | null> {
  if (!accessToken) return null;
  const res = await fetch("https://api.github.com/user/emails", {
    headers: {
      authorization: `Bearer ${accessToken}`,
      accept: "application/vnd.github.v3+json",
      "user-agent": "zitadel-actions-worker",
    },
  });
  if (res.status !== 200) {
    console.warn(`[github] /user/emails -> ${res.status}`);
    return null;
  }
  const emails = (await res.json()) as Array<
    { email: string; primary: boolean }
  >;
  return emails.find((e) => e.primary)?.email ?? null;
}

// Mirror the old v1 action's name split: first word is given name, the rest is
// family name (defaulting to a single space, which ZITADEL requires non-empty).
export function splitName(
  login: string | undefined,
  name: unknown,
): { firstName: string; lastName: string } {
  let firstName = login ?? "";
  let lastName = " ";
  const parts = String(name ?? "").trim().split(" ");
  if (parts.length > 0 && parts[0].length > 0) firstName = parts[0];
  if (parts.length > 1) lastName = parts.slice(1).join(" ");
  return { firstName, lastName };
}

async function updateHumanUser(
  env: Env,
  userId: string,
  email: string,
  firstName: string,
  lastName: string,
): Promise<void> {
  const res = await fetch(
    `https://${env.ZITADEL_DOMAIN}/v2/users/human/${userId}`,
    {
      method: "PUT",
      headers: {
        authorization: `Bearer ${env.ZITADEL_TOKEN}`,
        "content-type": "application/json",
      },
      body: JSON.stringify({
        // displayName isn't auto-derived on update (only at creation), so set it.
        profile: {
          givenName: firstName,
          familyName: lastName,
          displayName: `${firstName} ${lastName}`,
        },
        email: { email, isVerified: true },
      }),
    },
  );
  const text = await res.text();
  if (!res.ok) {
    throw new Error(`UpdateHumanUser ${userId} -> ${res.status} ${text}`);
  }
  console.log(
    `[idp-intent] updated ${userId} email=${email} name="${firstName} ${lastName}"`,
  );
}

// --- /token : preuserinfo (roles) + presamlresponse (saml) ---------------
// Ports the v1 mapRoles / samlMapRoles actions. Dispatched by the function the
// execution is bound to.

interface UserGrant {
  project_id: string;
  roles: string[];
}

interface TokenBody {
  function?: string;
  userinfo?: Record<string, unknown>;
  user_grants?: UserGrant[];
  user?: { id?: string };
}

async function handleToken(body: TokenBody, env: Env): Promise<Manipulation> {
  switch (body?.function) {
    case "function/preuserinfo":
      return mapRoles(body);
    case "function/presamlresponse":
      return await mapSamlRoles(body, env);
    default:
      console.log(`[token] unhandled function ${body?.function}`);
      return {};
  }
}

// mapRoles: for the project this token is being issued for (identified by the
// asserted `urn:zitadel:iam:org:project:<id>:roles` claim), emit the user's
// roles for that project as a `role` (single grant) or `roles` (multiple)
// claim — matching the v1 action's shape exactly.
//
// `roles` is one entry per GRANT, each entry being that grant's role array.
// Quirks preserved for v1 parity: a single grant with multiple roles becomes
// `role: "A,B"` (String() comma-joins the array); multiple grants become
// `roles: [["A"], ["B"]]` (array of per-grant arrays). Don't "simplify" these
// without re-checking every downstream consumer.
export function mapRoles(body: TokenBody): Manipulation {
  const userinfo = body?.userinfo ?? {};
  const grants = body?.user_grants ?? [];

  const projectId = Object.keys(userinfo)
    .map((k) => k.match(/urn:zitadel:iam:org:project:(\d+):roles/)?.[1])
    .filter(Boolean)[0];
  if (!projectId) return {};

  const roles = grants.filter((g) => g.project_id === projectId).map((g) =>
    g.roles
  );
  if (roles.length === 1) {
    return { append_claims: [{ key: "role", value: String(roles[0]) }] };
  }
  if (roles.length > 1) {
    return { append_claims: [{ key: "roles", value: roles }] };
  }
  return {};
}

// samlMapRoles: emit every role the user holds (across all grants) as a `Roles`
// SAML attribute — matching the v1 action. Unlike preuserinfo, the
// presamlresponse payload carries no grants (only `user`), so fetch them from
// the management API by user id.
export async function mapSamlRoles(
  body: TokenBody,
  env: Env,
): Promise<Manipulation> {
  const userId = body?.user?.id;
  if (!userId) return {};

  const res = await fetch(
    `https://${env.ZITADEL_DOMAIN}/management/v1/users/grants/_search`,
    {
      method: "POST",
      headers: {
        authorization: `Bearer ${env.ZITADEL_TOKEN}`,
        "content-type": "application/json",
      },
      body: JSON.stringify({ queries: [{ userIdQuery: { userId } }] }),
    },
  );
  if (!res.ok) {
    // Loud: a failure here means the SAML assertion ships with no Roles, which
    // can silently drop SP-side access (e.g. OVHCloud admin).
    console.error(
      `[saml] grants search failed for ${userId}: ${res.status} — assertion will have no Roles`,
    );
    return {};
  }

  const data = (await res.json()) as {
    result?: Array<{ roleKeys?: string[] }>;
  };
  const roles = [
    ...new Set((data.result ?? []).flatMap((g) => g.roleKeys ?? [])),
  ];
  if (roles.length === 0) return {};

  return {
    append_attribute: [
      {
        name: "Roles",
        name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
        value: roles,
      },
    ],
  };
}

// --- signature -----------------------------------------------------------

// ZITADEL signs `${timestamp}.${rawBody}`. Reject signatures whose timestamp is
// outside this window so a captured request can't be replayed indefinitely.
const SIGNATURE_TOLERANCE_SECONDS = 300;

export async function verifySignature(
  signatureHeader: string,
  rawBody: string,
  signingKey: string,
): Promise<boolean> {
  const parts = signatureHeader.split(",");
  const timestamp = parts.find((e) => e.startsWith("t="))?.slice(2);
  const signature = parts.find((e) => e.startsWith("v1="))?.slice(3);
  if (!timestamp || !signature) return false;

  const ts = Number(timestamp);
  if (
    !Number.isFinite(ts) ||
    Math.abs(Date.now() / 1000 - ts) > SIGNATURE_TOLERANCE_SECONDS
  ) {
    console.warn(`[verify] timestamp outside tolerance (t=${timestamp})`);
    return false;
  }

  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(signingKey),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign(
    "HMAC",
    key,
    encoder.encode(`${timestamp}.${rawBody}`),
  );
  const computed = Array.from(new Uint8Array(sig))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
  return computed === signature;
}
