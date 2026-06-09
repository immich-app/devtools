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
// key. Secrets/config are injected as Worker bindings (see env below).

export default {
  async fetch(req, env) {
    const url = new URL(req.url);

    if (req.method !== "POST") {
      return new Response("Not found", { status: 404 });
    }

    switch (url.pathname) {
      case "/idp-intent":
        return handleVerified(req, env.IDP_INTENT_SIGNING_KEY, (body) => handleIdpIntent(body, env));
      case "/token":
        return handleVerified(req, env.TOKEN_SIGNING_KEY, (body) => handleToken(body, env));
      default:
        return new Response("Not found", { status: 404 });
    }
  },
};

// Verify the ZITADEL signature, parse JSON, hand off to `handler`, and turn its
// return value into a JSON 200. A thrown handler error becomes a 500 — with
// interrupt_on_error=false on the target, ZITADEL ignores it and the login
// proceeds unchanged, so a worker fault can never break authentication.
async function handleVerified(req, signingKey, handler) {
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

  let body;
  try {
    body = JSON.parse(rawBody);
  } catch {
    return new Response("Invalid JSON", { status: 400 });
  }

  try {
    const result = (await handler(body)) ?? {};
    return Response.json(result);
  } catch (e) {
    console.error("[handler] error:", e?.stack ?? e?.message ?? e);
    return new Response("Internal error", { status: 500 });
  }
}

// --- /idp-intent : profile sync ------------------------------------------

async function handleIdpIntent(body, env) {
  const idp = body?.response?.idpInformation;
  const userId = body?.response?.userId;
  if (!idp || !userId) {
    console.log("[idp-intent] no idpInformation/userId — skipping");
    return {};
  }

  const raw = idp.rawInformation ?? {};
  let email = null;
  let firstName;
  let lastName;

  if (idp.idpId === env.GITHUB_IDP_ID) {
    // GitHub: primary email comes from /user/emails (profile email may be null
    // when the user keeps it private); name split mirrors the old v1 action.
    email = (await githubPrimaryEmail(idp?.oauth?.accessToken)) ?? raw.email ?? null;
    ({ firstName, lastName } = splitName(raw.login ?? idp.userName, raw.name));
  } else if (idp.idpId === env.GITLAB_IDP_ID) {
    // GitLab is OIDC — email + name are already in the userinfo.
    email = raw.email ?? null;
    ({ firstName, lastName } = splitName(raw.nickname ?? raw.preferred_username ?? idp.userName, raw.name));
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

async function githubPrimaryEmail(accessToken) {
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
  const emails = await res.json();
  return emails.find((e) => e.primary)?.email ?? null;
}

// Mirror the old v1 action's name split: first word is given name, the rest is
// family name (defaulting to a single space, which ZITADEL requires non-empty).
function splitName(login, name) {
  let firstName = login;
  let lastName = " ";
  const parts = String(name ?? "").trim().split(" ");
  if (parts.length > 0 && parts[0].length > 0) firstName = parts[0];
  if (parts.length > 1) lastName = parts.slice(1).join(" ");
  return { firstName, lastName };
}

async function updateHumanUser(env, userId, email, firstName, lastName) {
  const res = await fetch(`https://${env.ZITADEL_DOMAIN}/v2/users/human/${userId}`, {
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
  });
  const text = await res.text();
  if (!res.ok) {
    throw new Error(`UpdateHumanUser ${userId} -> ${res.status} ${text}`);
  }
  console.log(`[idp-intent] updated ${userId} email=${email} name="${firstName} ${lastName}"`);
}

// --- /token : preuserinfo (roles) + presamlresponse (saml) ---------------
// Phase 2: port mapRoles -> append_claims(role/roles) from body.user_grants,
// and samlMapRoles -> Roles SAML attribute. Until then this is an inert no-op
// (returns {}), so wiring the execution early can't change any token.

async function handleToken(body) {
  const fn = body?.function;
  console.log(`[token] received ${fn} — handler not yet implemented (no-op)`);
  return {};
}

// --- signature -----------------------------------------------------------

async function verifySignature(signatureHeader, rawBody, signingKey) {
  const parts = signatureHeader.split(",");
  const timestamp = parts.find((e) => e.startsWith("t="))?.slice(2);
  const signature = parts.find((e) => e.startsWith("v1="))?.slice(3);
  if (!timestamp || !signature) return false;

  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(signingKey),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign("HMAC", key, encoder.encode(`${timestamp}.${rawBody}`));
  const computed = Array.from(new Uint8Array(sig))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
  return computed === signature;
}
