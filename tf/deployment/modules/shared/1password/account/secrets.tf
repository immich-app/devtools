module "manual-secrets" {
  source = "./shared/modules/secrets/manual"

  secrets = {
    global = [
      "IMMICH_DISCORD_BOT_TOKEN",
      "IMMICH_ZULIP_BOT_USERNAME",
      "IMMICH_ZULIP_BOT_API_KEY",
      "IMMICH_ZULIP_USER_USERNAME",
      "IMMICH_ZULIP_USER_API_KEY",
      "IMMICH_GITHUB_CLIENT_ID",
      "IMMICH_GITHUB_CLIENT_SECRET",
      "FUTO_ZULIP_DOMAIN",
      "FOURTHWALL_USER",
      "FOURTHWALL_PASSWORD",
      "OUTLINE_API_KEY",
      "IMMICH_TF_DISCORD_BOT_TOKEN",
      "FLUXCD_GITHUB_WEBHOOK_URL",
      "PREVIEWS_GITHUB_WEBHOOK_URL",
      "GITHUB_OAUTH_APP_IMMICH_ZITADEL_CLIENT_ID",
      "GITHUB_OAUTH_APP_IMMICH_ZITADEL_CLIENT_SECRET",
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
      { name = "OUTLINE_SECRET_KEY", length = 32 },
      { name = "OUTLINE_UTILS_SECRET"}
    ]
  }
}

module "github-apps" {
  source = "./shared/modules/secrets/github-app"

  app_names = ["IMMICH_TOFU", "IMMICH_PUSH_O_MATIC", "IMMICH_READ_ONLY"]
}

