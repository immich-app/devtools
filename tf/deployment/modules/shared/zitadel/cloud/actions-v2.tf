// ZITADEL Actions v2 + the Cloudflare Worker that backs them, kept together.
//
// Phase 1 (here): the /idp-intent webhook on RetrieveIdentityProviderIntent —
// the worker (services/zitadel-actions) syncs the external IdP's real email +
// name onto the ZITADEL user via the management API before the token is issued.
// Additive: the v1 mapGitHubOAuth/mapGitLabOAuth actions stay until the worker
// is proven in prod, then they're retired.
//
// Phase 2 (later): a /token REST_CALL target on the preuserinfo /
// presamlresponse functions to replace mapRoles / samlMapRoles.

locals {
  zitadel_actions_worker_host = "zitadel-actions.internal.immich.cloud"
}

// --- ZITADEL action target + execution -----------------------------------

resource "zitadel_action_target" "idp_intent" {
  name               = "zitadel-actions-idp-intent"
  endpoint           = "https://${local.zitadel_actions_worker_host}/idp-intent"
  target_type        = "REST_WEBHOOK"
  timeout            = "10s"
  interrupt_on_error = false
  payload_type       = "PAYLOAD_TYPE_JSON"
}

resource "zitadel_action_execution_response" "idp_intent" {
  method     = "/zitadel.user.v2.UserService/RetrieveIdentityProviderIntent"
  target_ids = [zitadel_action_target.idp_intent.id]
}

// /token (REST_CALL) — the worker returns claim/attribute manipulation for the
// token-customization functions: preuserinfo maps project roles to the
// role/roles claim (was mapRoles), presamlresponse emits the Roles SAML
// attribute (was samlMapRoles). The v1 actions are removed in the same change,
// so there's no duplicate-claim / duplicate-attribute overlap.
resource "zitadel_action_target" "token" {
  name               = "zitadel-actions-token"
  endpoint           = "https://${local.zitadel_actions_worker_host}/token"
  target_type        = "REST_CALL"
  timeout            = "10s"
  interrupt_on_error = false
  payload_type       = "PAYLOAD_TYPE_JSON"
}

resource "zitadel_action_execution_function" "preuserinfo" {
  name       = "preuserinfo"
  target_ids = [zitadel_action_target.token.id]
}

resource "zitadel_action_execution_function" "presamlresponse" {
  name       = "presamlresponse"
  target_ids = [zitadel_action_target.token.id]
}

// --- Cloudflare Worker (provider v5: worker + version + deployment) -------

# The worker source is TypeScript; Cloudflare runs JS. Transpile it at plan time
# (deno, provided via mise) so the deployed content is always in sync with the
# source — build.ts prints {"js": "..."} on stdout.
data "external" "zitadel_actions_worker_build" {
  program = ["deno", "run", "--allow-read", "--allow-net", "--allow-env", "${var.zitadel_actions_worker_dir}/scripts/build.ts"]
}

resource "cloudflare_worker" "zitadel_actions" {
  account_id = var.cloudflare_account_id
  name       = "zitadel-actions"
}

resource "cloudflare_worker_version" "zitadel_actions" {
  account_id         = var.cloudflare_account_id
  worker_id          = cloudflare_worker.zitadel_actions.id
  compatibility_date = "2026-06-01"
  main_module        = "index.js"

  # Embed the transpiled content (not a file path) so a code change produces a
  # config diff and terraform cuts a new version + redeploys.
  modules = [{
    name           = "index.js"
    content_base64 = base64encode(data.external.zitadel_actions_worker_build.result.js)
    content_type   = "application/javascript+module"
  }]

  bindings = [
    { name = "ZITADEL_DOMAIN", type = "plain_text", text = var.futo_zitadel_base_domain },
    { name = "GITHUB_IDP_ID", type = "plain_text", text = zitadel_idp_github.github.id },
    { name = "GITLAB_IDP_ID", type = "plain_text", text = zitadel_idp_gitlab_self_hosted.gitlab.id },
    { name = "ZITADEL_TOKEN", type = "secret_text", text = zitadel_personal_access_token.zitadel_actions.token },
    { name = "IDP_INTENT_SIGNING_KEY", type = "secret_text", text = zitadel_action_target.idp_intent.signing_key },
    { name = "TOKEN_SIGNING_KEY", type = "secret_text", text = zitadel_action_target.token.signing_key },
  ]
}

resource "cloudflare_workers_deployment" "zitadel_actions" {
  account_id  = var.cloudflare_account_id
  script_name = cloudflare_worker.zitadel_actions.name
  strategy    = "percentage"

  versions = [{
    percentage = 100
    version_id = cloudflare_worker_version.zitadel_actions.id
  }]
}

resource "cloudflare_workers_custom_domain" "zitadel_actions" {
  account_id = var.cloudflare_account_id
  hostname   = local.zitadel_actions_worker_host
  service    = cloudflare_worker.zitadel_actions.name
  zone_name  = "immich.cloud"

  # A custom domain can only attach once the worker has a live deployment.
  depends_on = [cloudflare_workers_deployment.zitadel_actions]
}
