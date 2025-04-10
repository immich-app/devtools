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

data "onepassword_item" "previews_webhook_secret" {
  title = "previews-webhook-secret"
  vault = data.onepassword_vault.kubernetes.name
}

locals {
  previews_webhook_token = [for field in data.onepassword_item.previews_webhook_secret.section[0].field : field.value if field.label == "token"][0]
}

resource "github_repository_webhook" "previews" {
  events = [
    "push",
    "pull_request"
  ]
  repository = "immich"
  configuration {
    url          = data.onepassword_item.previews_webhook_secret.url
    secret       = local.previews_webhook_token
    content_type = "form"
  }
}
