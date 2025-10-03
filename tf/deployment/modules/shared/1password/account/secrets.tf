module "manual-secrets" {
  source = "./shared/modules/secrets/manual"

  secrets = {
    global = [
      "IMMICH_DISCORD_BOT_TOKEN",
      "IMMICH_ZULIP_BOT_USERNAME",
      "IMMICH_ZULIP_BOT_API_KEY",
      "IMMICH_ZULIP_USER_USERNAME",
      "IMMICH_ZULIP_USER_API_KEY",
      "FUTO_ZULIP_DOMAIN",
      "FOURTHWALL_USER",
      "FOURTHWALL_PASSWORD",
      "OUTLINE_API_KEY",
      "IMMICH_TF_DISCORD_BOT_TOKEN",
      "FLUXCD_GITHUB_WEBHOOK_URL",
      "PREVIEWS_GITHUB_WEBHOOK_URL",
      "GITHUB_OAUTH_APP_IMMICH_ZITADEL_CLIENT_ID",
      "GITHUB_OAUTH_APP_IMMICH_ZITADEL_CLIENT_SECRET",
      "DIGITALOCEAN_API_TOKEN",
      "TIGRIS_READ_KEY_ID",
      "TIGRIS_READ_ACCESS_KEY",
      "TIGRIS_WRITE_KEY_ID",
      "TIGRIS_WRITE_ACCESS_KEY",
      "TIGRIS_ADMIN_KEY_ID",
      "TIGRIS_ADMIN_ACCESS_KEY",
      "WEBLATE_API_KEY",
      "VULTR_API_TOKEN",
      "GOOGLE_PLAY_SIGNING_KEY_JKS",
      "GOOGLE_PLAY_SIGNING_KEY_ALIAS",
      "GOOGLE_PLAY_SIGNING_KEY_PASSWORD",
      "GOOGLE_PLAY_SIGNING_KEY_STORE_PASSWORD"
    ]
    dev = [
      "MONITORING_GRAFANA_TF_AUTH_TOKEN",
      "MONITORING_GRAFANA_URL",
      "IMMICH_DISCORD_SERVER_ID",
    ]
    prod = [
      "MONITORING_GRAFANA_TF_AUTH_TOKEN",
      "MONITORING_GRAFANA_URL",
      "IMMICH_DISCORD_SERVER_ID",
    ]
  }
}

module "generated-secrets" {
  source = "./shared/modules/secrets/generated"

  secrets = {
    global = [
      { name = "IMMICH_DISCORD_BOT_GITHUB_STATUS_SLUG" },
      { name = "IMMICH_DISCORD_BOT_STRIPE_PAYMENT_SLUG" },
      { name = "IMMICH_DISCORD_BOT_GITHUB_WEBHOOK_SLUG" },
      { name = "IMMICH_DISCORD_BOT_FOURTHWALL_WEBHOOK_SLUG" },
      { name = "FLUXCD_GITHUB_WEBHOOK_SECRET" },
      { name = "PREVIEWS_GITHUB_WEBHOOK_SECRET" },
      { name = "AUTH_ZITADEL_MASTER_KEY", length = 32 },
      { name = "OUTLINE_SECRET_KEY", length = 64, type = "numeric" },
      { name = "OUTLINE_UTILS_SECRET" },
      { name = "OUTLINE_VOLSYNC_BACKUPS_RESTIC_SECRET" },
      { name = "VICTORIALOGS_VOLSYNC_BACKUPS_RESTIC_SECRET" },
      { name = "OAUTH2_PROXY_COOKIE_SECRET", length = 32 },
      { name = "IMMICH_GITHUB_ACTION_CHECKS_WEBHOOK_SECRET" }
    ]
    dev = [
      { name = "METRICS_READ_TOKEN" },
      { name = "METRICS_WRITE_TOKEN" },
      { name = "METRICS_ADMIN_TOKEN" }
    ]
    prod = [
      { name = "METRICS_READ_TOKEN" },
      { name = "METRICS_WRITE_TOKEN" },
      { name = "METRICS_ADMIN_TOKEN" },
      { name = "LOGS_WRITE_TOKEN" }
    ]
  }
}

module "github-apps" {
  source = "./shared/modules/secrets/github-app"

  app_names = ["IMMICH_TOFU", "IMMICH_PUSH_O_MATIC", "IMMICH_READ_ONLY", "IMMICH_GITHUB_ACTION_CHECKS"]
}
