data "onepassword_item" "bot" {
  title = "bot-github-webhook-slug"
  vault = data.onepassword_vault.kubernetes.name
}

resource "github_organization_webhook" "bot" {
  events = [
    "discussion",
    "issues",
    "pull_request",
    "release"
  ]
  configuration {
    url          = "https://api.immich.app/webhooks/github/${data.onepassword_item.bot.section[0].field[0].value}"
    content_type = "json"
  }
}
