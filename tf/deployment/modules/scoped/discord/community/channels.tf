locals {
  channel_order = [
    # No Category - Top Level
    "rules",
    "welcome",
    "announcements",
    "poll",
    # Immich Category
    "help_desk_support",
    "support_crew",
    "package_maintainers",
    "focus_discussion",
    "contributing",
    "translations",
    "immich",
    "merch",
    # Community Category
    "imagegenius_aio",
    "immich_go",
    "immich_frame",
    "immich_kiosk",
    "immich_power_tools",
    "truenas",
    "unraid",
    # Development Category
    "dev",
    "dev_off_topic",
    "dev_announcements",
    "dev_focus_topic",
    # Team Category
    "team",
    "team_off_topic",
    "team_focus_topic",
    "team_purchases",
    "team_alerts",
    # Leadership Category
    "leadership",
    "leadership_off_topic",
    "leadership_alerts",
    "leadership_focus_topic",
    "moderator_only",
    # Third Parties Category
    "developer_updates",
    "cloudflare_status",
    "github_status",
    "github_issues_and_discussion",
    "github_pull_requests",
    "github_releases",
    # Off Topic Category
    "bot_spam",
    "emotes",
    "off_topic",
    # Voice Category
    "immich_voice",
    "dev_voice",
    "team_voice",
    "leadership_voice",
  ]
}

data "discord_permission" "view_channel" {
  view_channel = "allow"
}

resource "discord_text_channel" "rules" {
  name                     = "rules"
  position                 = index(local.channel_order, "rules")
  server_id                = discord_server.server.id
  sync_perms_with_category = false
}

resource "discord_text_channel" "welcome" {
  name                     = "welcome"
  position                 = index(local.channel_order, "welcome")
  server_id                = discord_server.server.id
  sync_perms_with_category = false
}

resource "discord_news_channel" "announcements" {
  name                     = "announcements"
  position                 = index(local.channel_order, "announcements")
  server_id                = discord_server.server.id
  sync_perms_with_category = false
}

resource "discord_news_channel" "poll" {
  name                     = "poll"
  topic                    = "Community driven choices"
  position                 = index(local.channel_order, "poll")
  server_id                = discord_server.server.id
  sync_perms_with_category = false
}

# resource "discord_forum_channel" "help_desk_support" {
#   name      = "help-desk-support"
#   position  = index(local.channel_order, "help_desk_support")
#   server_id = discord_server.server.id
#   category = discord_category_channel.immich.id
# }
#
# import {
#   id = 1049703391762321418
#   to = discord_forum_channel.help_desk_support
# }

resource "discord_text_channel" "support_crew" {
  name                     = "support-crew"
  position                 = index(local.channel_order, "support_crew")
  category                 = discord_category_channel.immich.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
}

resource "discord_text_channel" "package_maintainers" {
  name                     = "package-maintainers"
  position                 = index(local.channel_order, "package_maintainers")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.immich.id
  sync_perms_with_category = false
}

# resource "discord_forum_channel" "focus_discussion" {
#   name      = "focus-discussion"
#   position  = index(local.channel_order, "focus_discussion")
#   server_id = discord_server.server.id
#   category  = discord_category_channel.immich.id
# }
#
# import {
#   id = 1026327300284887111
#   to = discord_forum_channel.focus_discussion
# }

resource "discord_text_channel" "contributing" {
  name      = "contributing"
  topic     = "Discuss technical topics on contributing to the Immich codebase. Not for support/troubleshooting."
  position  = index(local.channel_order, "contributing")
  category  = discord_category_channel.immich.id
  server_id = discord_server.server.id
}

resource "discord_text_channel" "translations" {
  name      = "translations"
  topic     = "https://hosted.weblate.org/projects/immich/immich/"
  position  = index(local.channel_order, "translations")
  category  = discord_category_channel.immich.id
  server_id = discord_server.server.id
}

resource "discord_text_channel" "immich" {
  name      = "immich"
  topic     = "General discussion about everything Immich"
  position  = index(local.channel_order, "immich")
  category  = discord_category_channel.immich.id
  server_id = discord_server.server.id
}

resource "discord_text_channel" "merch" {
  name      = "merch"
  topic     = "https://immich.store"
  position  = index(local.channel_order, "merch")
  category  = discord_category_channel.immich.id
  server_id = discord_server.server.id
}

resource "discord_text_channel" "imagegenius_aio" {
  name      = "imagegenius-aio"
  topic     = "Discussion channel for the all-in-one image - https://github.com/imagegenius/docker-immich"
  position  = index(local.channel_order, "imagegenius_aio")
  category  = discord_category_channel.community.id
  server_id = discord_server.server.id
}

resource "discord_text_channel" "immich_go" {
  name                     = "immich-go"
  topic                    = "Discussion channel for the immich-go upload tool - https://github.com/simulot/immich-go"
  position                 = index(local.channel_order, "immich_go")
  category                 = discord_category_channel.community.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
}

resource "discord_text_channel" "immich_frame" {
  name                     = "immich-frame"
  topic                    = "Discussion for the https://github.com/immichFrame/ImmichFrame project"
  position                 = index(local.channel_order, "immich_frame")
  category                 = discord_category_channel.community.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
}

resource "discord_text_channel" "immich_kiosk" {
  name                     = "immich-kiosk"
  topic                    = "https://github.com/damongolding/immich-kiosk"
  position                 = index(local.channel_order, "immich_kiosk")
  category                 = discord_category_channel.community.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
}

resource "discord_text_channel" "immich_power_tools" {
  name                     = "immich-power-tools"
  topic                    = "Discussion channel for the immich power tools — https://github.com/varun-raj/immich-power-tools"
  position                 = index(local.channel_order, "immich_power_tools")
  category                 = discord_category_channel.community.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
}

resource "discord_text_channel" "truenas" {
  name      = "truenas"
  topic     = "Discussion channel for the truenas immich app"
  position  = index(local.channel_order, "truenas")
  category  = discord_category_channel.community.id
  server_id = discord_server.server.id
}

resource "discord_text_channel" "unraid" {
  name      = "unraid"
  topic     = "Discussion channel for Immich on unraid"
  position  = index(local.channel_order, "unraid")
  category  = discord_category_channel.community.id
  server_id = discord_server.server.id
}

resource "discord_text_channel" "dev" {
  name      = "dev"
  position  = index(local.channel_order, "dev")
  category  = discord_category_channel.development.id
  server_id = discord_server.server.id
}

resource "discord_text_channel" "dev_off_topic" {
  name      = "dev-off-topic"
  topic     = "Development parking lot conversation"
  position  = index(local.channel_order, "dev_off_topic")
  category  = discord_category_channel.development.id
  server_id = discord_server.server.id
}

# resource "discord_forum_channel" "dev_announcements" {
#   name      = "dev-announcements"
#   position  = index(local.channel_order, "dev_announcements")
#   server_id = discord_server.server.id
#   category  = discord_category_channel.development.id
# }
#
# import {
#   id = 1073000522338017381
#   to = discord_forum_channel.dev_announcements
# }

# resource "discord_forum_channel" "dev_focus_topic" {
#   name      = "dev-focus-topic"
#   position  = index(local.channel_order, "dev_focus_topic")
#   server_id = discord_server.server.id
#   category  = discord_category_channel.development.id
# }
#
# import {
#   id = 1045707766754451486
#   to = discord_forum_channel.dev_focus_topic
# }

resource "discord_text_channel" "team" {
  name      = "team"
  position  = index(local.channel_order, "team")
  server_id = discord_server.server.id
  category  = discord_category_channel.team.id
}

resource "discord_text_channel" "team_off_topic" {
  name      = "team-off-topic"
  position  = index(local.channel_order, "team_off_topic")
  server_id = discord_server.server.id
  category  = discord_category_channel.team.id
}

# resource "discord_forum_channel" "team_focus_topic" {
#   name      = "team-focus-topic"
#   position  = index(local.channel_order, "team_focus_topic")
#   server_id = discord_server.server.id
#   category  = discord_category_channel.team.id
# }
#
# import {
#   id = 1330248543721754746
#   to = discord_forum_channel.team_focus_topic
# }

resource "discord_text_channel" "team_alerts" {
  name      = "team-alerts"
  position  = index(local.channel_order, "team_alerts")
  server_id = discord_server.server.id
  category  = discord_category_channel.team.id
}

resource "discord_text_channel" "team_purchases" {
  name      = "team-purchases"
  position  = index(local.channel_order, "team_purchases")
  server_id = discord_server.server.id
  category  = discord_category_channel.team.id
}

moved {
  from = discord_text_channel.leadership_purchases
  to   = discord_text_channel.team_purchases
}

resource "discord_text_channel" "leadership" {
  name      = "leadership"
  topic     = "The place we make decisions that we know nothing about"
  position  = index(local.channel_order, "leadership")
  server_id = discord_server.server.id
  category  = discord_category_channel.leadership.id
}

resource "discord_text_channel" "leadership_off_topic" {
  name      = "leadership-off-topic"
  position  = index(local.channel_order, "leadership_off_topic")
  server_id = discord_server.server.id
  category  = discord_category_channel.leadership.id
}

resource "discord_text_channel" "leadership_alerts" {
  name      = "leadership-alerts"
  position  = index(local.channel_order, "leadership_alerts")
  server_id = discord_server.server.id
  category  = discord_category_channel.leadership.id
}

# resource "discord_forum_channel" "leadership_focus_topic" {
#   name      = "leadership-focus-topic"
#   position  = index(local.channel_order, "leadership_focus_topic")
#   server_id = discord_server.server.id
#   category  = discord_category_channel.leadership.id
# }
#
# import {
#   id = 1229454284479795291
#   to = discord_forum_channel.leadership_focus_topic
# }

resource "discord_text_channel" "moderator_only" {
  name      = "moderator-only"
  position  = index(local.channel_order, "moderator_only")
  server_id = discord_server.server.id
  category  = discord_category_channel.leadership.id
}

resource "discord_text_channel" "developer_updates" {
  name      = "developer-updates"
  position  = index(local.channel_order, "developer_updates")
  server_id = discord_server.server.id
  category  = discord_category_channel.third_parties.id
}

resource "discord_text_channel" "cloudflare_status" {
  name      = "cloudflare-status"
  position  = index(local.channel_order, "cloudflare_status")
  server_id = discord_server.server.id
  category  = discord_category_channel.third_parties.id
}

resource "discord_text_channel" "github_status" {
  name      = "github-status"
  topic     = "https://www.githubstatus.com"
  position  = index(local.channel_order, "github_status")
  server_id = discord_server.server.id
  category  = discord_category_channel.third_parties.id
}

resource "discord_text_channel" "github_issues_and_discussion" {
  name      = "github-issues-and-discussion"
  topic     = "New GitHub issue and discussion thread"
  position  = index(local.channel_order, "github_issues_and_discussion")
  server_id = discord_server.server.id
  category  = discord_category_channel.third_parties.id
}

resource "discord_text_channel" "github_pull_requests" {
  name      = "github-pull-requests"
  position  = index(local.channel_order, "github_pull_requests")
  server_id = discord_server.server.id
  category  = discord_category_channel.third_parties.id
}

resource "discord_news_channel" "github_releases" {
  name      = "github-releases"
  position  = index(local.channel_order, "github_releases")
  server_id = discord_server.server.id
  category  = discord_category_channel.third_parties.id
}

resource "discord_text_channel" "bot_spam" {
  name                     = "bot-spam"
  position                 = index(local.channel_order, "bot_spam")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.off_topic.id
  sync_perms_with_category = false
}

resource "discord_text_channel" "emotes" {
  name                     = "emotes"
  position                 = index(local.channel_order, "emotes")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.off_topic.id
  sync_perms_with_category = false
}

resource "discord_text_channel" "off_topic" {
  name      = "off-topic"
  topic     = "Your retro chatroom with an Immich theme"
  position  = index(local.channel_order, "off_topic")
  server_id = discord_server.server.id
  category  = discord_category_channel.off_topic.id
}

resource "discord_voice_channel" "immich_voice" {
  name                     = "immich-voice"
  position                 = index(local.channel_order, "immich_voice")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.voice.id
  sync_perms_with_category = false
}

resource "discord_voice_channel" "dev_voice" {
  name                     = "dev-voice"
  position                 = index(local.channel_order, "dev_voice")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.voice.id
  sync_perms_with_category = false
}

resource "discord_voice_channel" "team_voice" {
  name                     = "team-voice"
  position                 = index(local.channel_order, "team_voice")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.voice.id
  sync_perms_with_category = false
}

resource "discord_voice_channel" "leadership_voice" {
  name                     = "leadership-voice"
  position                 = index(local.channel_order, "leadership_voice")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.voice.id
  sync_perms_with_category = false
}
