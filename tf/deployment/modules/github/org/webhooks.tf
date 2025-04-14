data "onepassword_item" "bot" {
  title = "IMMICH_DISCORD_BOT_GITHUB_WEBHOOK_SLUG"
  vault = data.onepassword_vault.tf.name
}

resource "github_organization_webhook" "bot" {
  events = [
    "discussion",
    "issues",
    "pull_request",
    "release"
  ]
  configuration {
    url          = "https://api.immich.app/webhooks/github/${data.onepassword_item.bot.password}"
    content_type = "json"
  }
}

data "onepassword_item" "previews_webhook_url" {
  title = "PREVIEWS_GITHUB_WEBHOOK_URL"
  vault = data.onepassword_vault.tf.name
}

data "onepassword_item" "previews_webhook_secret" {
  title = "PREVIEWS_GITHUB_WEBHOOK_SECRET"
  vault = data.onepassword_vault.tf.name
}

resource "github_repository_webhook" "previews" {
  count = data.onepassword_item.previews_webhook_url.password != "REPLACE_ME" ? 1 : 0
  events = [
    "push",
    "pull_request"
  ]
  repository = "immich"
  configuration {
    url          = data.onepassword_item.previews_webhook_url.password
    secret       = data.onepassword_item.previews_webhook_secret.password
    content_type = "form"
  }
}

data "onepassword_item" "fluxcd_webhook_url" {
  title = "FLUXCD_GITHUB_WEBHOOK_URL"
  vault = data.onepassword_vault.tf.name
}

data "onepassword_item" "fluxcd_webhook_secret" {
  title = "FLUXCD_GITHUB_WEBHOOK_SECRET"
  vault = data.onepassword_vault.tf.name
}

resource "github_repository_webhook" "fluxcd" {
  count = data.onepassword_item.fluxcd_webhook_url.password != "REPLACE_ME" ? 1 : 0
  events = [
    "push",
    "pull_request"
  ]
  repository = "devtools"
  configuration {
    url          = data.onepassword_item.fluxcd_webhook_url.password
    secret       = data.onepassword_item.fluxcd_webhook_secret.password
    content_type = "form"
  }
}

