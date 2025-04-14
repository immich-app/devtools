module "manual-secrets" {
  source = "./shared/modules/secrets/manual"

  secrets = {
    global = [
      "IMMICH_DISCORD_BOT_TOKEN",
      "IMMICH_ZULIP_BOT_USERNAME",
      "IMMICH_ZULIP_BOT_API_KEY",
      "IMMICH_GITHUB_CLIENT_ID",
      "IMMICH_GITHUB_CLIENT_SECRET",
      "FUTO_ZULIP_DOMAIN",
      "FOURTHWALL_USER",
      "FOURTHWALL_PASSWORD",
      "OUTLINE_API_KEY",
      "IMMICH_TF_DISCORD_BOT_TOKEN"
    ]
  }
}

module "generated-secrets" {
  source = "./shared/modules/secrets/generated"

  secrets = {
    global = [
      "IMMICH_DISCORD_BOT_GITHUB_STATUS_SLUG",
      "IMMICH_DISCORD_BOT_STRIPE_PAYMENT_SLUG",
      "IMMICH_DISCORD_BOT_GITHUB_WEBHOOK_SLUG",
      "IMMICH_DISCORD_BOT_FOURTHWALL_WEBHOOK_SLUG"
    ]
  }
}

module "github-apps" {
  source = "./shared/modules/secrets/github-app"

  app_names = ["IMMICH_TOFU", "IMMICH_PUSH_O_MATIC", "IMMICH_READ_ONLY"]
}
