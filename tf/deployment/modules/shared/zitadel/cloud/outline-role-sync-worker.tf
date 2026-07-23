// Cloudflare Worker for outline-role-sync (replaces the in-cluster deno
// service). It receives Outline's users.signin webhook and reconciles the
// user's Outline groups/role from their ZITADEL grants. Deployed the same way
// as the zitadel-actions worker: deno transpiles the TS at plan time and the
// content is embedded so a code change forces a new version.
locals {
  outline_role_sync_worker_host = "outline-role-sync.internal.immich.cloud"
  # The Outline project's zitadel role keys are the Outline groups the worker
  # manages. Passing them in means adding a role to the project above is all
  # that's needed for the worker to start syncing its group.
  outline_role_keys = [
    for role in one([for p in local.projects_data : p.roles if p.name == "Outline"]) : role.key
  ]
}

# Outline API token + webhook secret live in 1Password (not created here).
data "onepassword_item" "outline_role_sync_api_token" {
  vault = data.onepassword_vault.tf.uuid
  title = "OUTLINE_ROLE_SYNC_OUTLINE_API_TOKEN"
}

data "onepassword_item" "outline_role_sync_webhook_secret" {
  vault = data.onepassword_vault.tf.uuid
  title = "OUTLINE_ROLE_SYNC_WEBHOOK_SECRET"
}

data "external" "outline_role_sync_worker_build" {
  program = ["deno", "run", "--allow-read", "--allow-net", "--allow-env", "${var.outline_role_sync_worker_dir}/scripts/build.ts"]
}

resource "cloudflare_worker" "outline_role_sync" {
  account_id = var.cloudflare_account_id
  name       = "outline-role-sync"
}

resource "cloudflare_worker_version" "outline_role_sync" {
  account_id         = var.cloudflare_account_id
  worker_id          = cloudflare_worker.outline_role_sync.id
  compatibility_date = "2026-06-01"
  main_module        = "index.js"

  modules = [{
    name           = "index.js"
    content_base64 = base64encode(data.external.outline_role_sync_worker_build.result.js)
    content_type   = "application/javascript+module"
  }]

  bindings = [
    { name = "OUTLINE_BASE_URL", type = "plain_text", text = "https://outline.immich.cloud" },
    { name = "ZITADEL_BASE_URL", type = "plain_text", text = "https://${var.futo_zitadel_base_domain}" },
    { name = "ZITADEL_OUTLINE_PROJECT_ID", type = "plain_text", text = zitadel_project.projects["Outline"].id },
    { name = "ZITADEL_OUTLINE_PROJECT_ROLES", type = "plain_text", text = join(",", local.outline_role_keys) },
    { name = "ZITADEL_SERVICE_ACCOUNT_TOKEN", type = "secret_text", text = zitadel_personal_access_token.outline_role_sync.token },
    { name = "OUTLINE_API_TOKEN", type = "secret_text", text = data.onepassword_item.outline_role_sync_api_token.password },
    { name = "OUTLINE_WEBHOOK_SECRET", type = "secret_text", text = data.onepassword_item.outline_role_sync_webhook_secret.password },
  ]
}

resource "cloudflare_workers_deployment" "outline_role_sync" {
  account_id  = var.cloudflare_account_id
  script_name = cloudflare_worker.outline_role_sync.name
  strategy    = "percentage"

  versions = [{
    percentage = 100
    version_id = cloudflare_worker_version.outline_role_sync.id
  }]
}

resource "cloudflare_workers_custom_domain" "outline_role_sync" {
  account_id = var.cloudflare_account_id
  hostname   = local.outline_role_sync_worker_host
  service    = cloudflare_worker.outline_role_sync.name
  zone_name  = "immich.cloud"

  depends_on = [cloudflare_workers_deployment.outline_role_sync]
}
