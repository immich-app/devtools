data "onepassword_item" "discord_discussions_and_issues" {
  title = "discord-issues-and-discussions-webhook"
  vault = data.onepassword_vault.opentofu_vault.name
}

resource "github_organization_webhook" "discord_discussions_and_issues" {
  events = [
    "discussion",
    "issues"
  ]
  configuration {
    url          = data.onepassword_item.discord_discussions_and_issues.credential
    content_type = "json"
  }
}

data "onepassword_item" "discord_pull_requests" {
  title = "discord-pull-requests-webhook"
  vault = data.onepassword_vault.opentofu_vault.name
}


resource "github_organization_webhook" "discord_pull_requests" {
  events = [
    "pull_request"
  ]
  configuration {
    url          = data.onepassword_item.discord_pull_requests.credential
    content_type = "json"
  }
}

data "onepassword_item" "discord_releases" {
  title = "discord-releases-webhook"
  vault = data.onepassword_vault.opentofu_vault.name
}

resource "github_organization_webhook" "discord_releases" {
  events = [
    "release"
  ]
  configuration {
    url          = data.onepassword_item.discord_releases.credential
    content_type = "json"
  }
}

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
