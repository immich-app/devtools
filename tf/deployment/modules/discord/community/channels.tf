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
    "team_alerts",
    # Leadership Category
    "leadership",
    "leadership_off_topic",
    "leadership_alerts",
    "leadership_purchases",
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

resource "discord_text_channel" "rules" {
  name                     = "rules"
  position                 = index(local.channel_order, "rules")
  server_id                = discord_server.server.id
  sync_perms_with_category = false
}

import {
  id = 991930223991988254
  to = discord_text_channel.rules
}

resource "discord_text_channel" "welcome" {
  name                     = "welcome"
  position                 = index(local.channel_order, "welcome")
  server_id                = discord_server.server.id
  sync_perms_with_category = false
}

import {
  id = 991479565052542976
  to = discord_text_channel.welcome
}

resource "discord_news_channel" "announcements" {
  name                     = "announcements"
  position                 = index(local.channel_order, "announcements")
  server_id                = discord_server.server.id
  sync_perms_with_category = false
}

import {
  id = 991930592843272342
  to = discord_news_channel.announcements
}

resource "discord_news_channel" "poll" {
  name                     = "poll"
  topic                    = "Community driven choices"
  position                 = index(local.channel_order, "poll")
  server_id                = discord_server.server.id
  sync_perms_with_category = false
}

import {
  id = 1005904323651309638
  to = discord_news_channel.poll
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

import {
  id = 1184258493948117084
  to = discord_text_channel.support_crew
}

resource "discord_text_channel" "package_maintainers" {
  name                     = "package-maintainers"
  position                 = index(local.channel_order, "package_maintainers")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.immich.id
  sync_perms_with_category = false
}

import {
  id = 1288859036015398974
  to = discord_text_channel.package_maintainers
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

import {
  id = 1071165397228855327
  to = discord_text_channel.contributing
}

resource "discord_text_channel" "translations" {
  name      = "translations"
  topic     = "https://hosted.weblate.org/projects/immich/immich/"
  position  = index(local.channel_order, "translations")
  category  = discord_category_channel.immich.id
  server_id = discord_server.server.id
}

import {
  id = 1250427404976132138
  to = discord_text_channel.translations
}

resource "discord_text_channel" "immich" {
  name      = "immich"
  topic     = "General discussion about everything Immich"
  position  = index(local.channel_order, "immich")
  category  = discord_category_channel.immich.id
  server_id = discord_server.server.id
}

import {
  id = 994044917355663450
  to = discord_text_channel.immich
}

resource "discord_text_channel" "merch" {
  name      = "merch"
  topic     = "https://immich.store"
  position  = index(local.channel_order, "merch")
  category  = discord_category_channel.immich.id
  server_id = discord_server.server.id
}

import {
  id = 1336794023888818288
  to = discord_text_channel.merch
}

resource "discord_text_channel" "imagegenius_aio" {
  name      = "imagegenius-aio"
  topic     = "Discussion channel for the all-in-one image - https://github.com/imagegenius/docker-immich"
  position  = index(local.channel_order, "imagegenius_aio")
  category  = discord_category_channel.community.id
  server_id = discord_server.server.id
}

import {
  id = 1178366211675930634
  to = discord_text_channel.imagegenius_aio
}

resource "discord_text_channel" "immich_go" {
  name                     = "immich-go"
  topic                    = "Discussion channel for the immich-go upload tool - https://github.com/simulot/immich-go"
  position                 = index(local.channel_order, "immich_go")
  category                 = discord_category_channel.community.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
}

import {
  id = 1178366369423700080
  to = discord_text_channel.immich_go
}

resource "discord_text_channel" "immich_frame" {
  name                     = "immich-frame"
  topic                    = "Discussion for the https://github.com/immichFrame/ImmichFrame project"
  position                 = index(local.channel_order, "immich_frame")
  category                 = discord_category_channel.community.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
}

import {
  id = 1217843270244372480
  to = discord_text_channel.immich_frame
}

resource "discord_text_channel" "immich_kiosk" {
  name                     = "immich-kiosk"
  topic                    = "https://github.com/damongolding/immich-kiosk"
  position                 = index(local.channel_order, "immich_kiosk")
  category                 = discord_category_channel.community.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
}

import {
  id = 1293191523927851099
  to = discord_text_channel.immich_kiosk
}

resource "discord_text_channel" "immich_power_tools" {
  name                     = "immich-power-tools"
  topic                    = "Discussion channel for the immich power tools — https://github.com/varun-raj/immich-power-tools"
  position                 = index(local.channel_order, "immich_power_tools")
  category                 = discord_category_channel.community.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
}

import {
  id = 1278195895594258553
  to = discord_text_channel.immich_power_tools
}

resource "discord_text_channel" "truenas" {
  name      = "truenas"
  topic     = "Discussion channel for the truenas immich app"
  position  = index(local.channel_order, "truenas")
  category  = discord_category_channel.community.id
  server_id = discord_server.server.id
}

import {
  id = 1178410588821524561
  to = discord_text_channel.truenas
}

resource "discord_text_channel" "unraid" {
  name      = "unraid"
  topic     = "Discussion channel for Immich on unraid"
  position  = index(local.channel_order, "unraid")
  category  = discord_category_channel.community.id
  server_id = discord_server.server.id
}

import {
  id = 1228387901889445989
  to = discord_text_channel.unraid
}

resource "discord_text_channel" "dev" {
  name      = "dev"
  position  = index(local.channel_order, "dev")
  category  = discord_category_channel.development.id
  server_id = discord_server.server.id
}

import {
  id = 979148343693422593
  to = discord_text_channel.dev
}

resource "discord_text_channel" "dev_off_topic" {
  name      = "dev-off-topic"
  topic     = "Development parking lot conversation"
  position  = index(local.channel_order, "dev_off_topic")
  category  = discord_category_channel.development.id
  server_id = discord_server.server.id
}

import {
  id = 1034520166115053638
  to = discord_text_channel.dev_off_topic
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

import {
  id = 1330248080271999086
  to = discord_text_channel.team
}

resource "discord_text_channel" "team_off_topic" {
  name      = "team-off-topic"
  position  = index(local.channel_order, "team_off_topic")
  server_id = discord_server.server.id
  category  = discord_category_channel.team.id
}

import {
  id = 1330252547751022632
  to = discord_text_channel.team_off_topic
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

import {
  id = 1360190417643110460
  to = discord_text_channel.team_alerts
}

resource "discord_text_channel" "leadership" {
  name      = "leadership"
  topic     = "The place we make decisions that we know nothing about"
  position  = index(local.channel_order, "leadership")
  server_id = discord_server.server.id
  category  = discord_category_channel.leadership.id
}

import {
  id = 1176686059422232636
  to = discord_text_channel.leadership
}

resource "discord_text_channel" "leadership_off_topic" {
  name      = "leadership-off-topic"
  position  = index(local.channel_order, "leadership_off_topic")
  server_id = discord_server.server.id
  category  = discord_category_channel.leadership.id
}

import {
  id = 1255863786686906489
  to = discord_text_channel.leadership_off_topic
}

resource "discord_text_channel" "leadership_alerts" {
  name      = "leadership-alerts"
  position  = index(local.channel_order, "leadership_alerts")
  server_id = discord_server.server.id
  category  = discord_category_channel.leadership.id
}

import {
  id = 1260975801625608213
  to = discord_text_channel.leadership_alerts
}

resource "discord_text_channel" "leadership_purchases" {
  name      = "leadership-purchases"
  position  = index(local.channel_order, "leadership_purchases")
  server_id = discord_server.server.id
  category  = discord_category_channel.leadership.id
}

import {
  id = 1263492970691297300
  to = discord_text_channel.leadership_purchases
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

import {
  id = 991930223991988255
  to = discord_text_channel.moderator_only
}

resource "discord_text_channel" "developer_updates" {
  name      = "developer-updates"
  position  = index(local.channel_order, "developer_updates")
  server_id = discord_server.server.id
  category  = discord_category_channel.third_parties.id
}

import {
  id = 1361300925788192778
  to = discord_text_channel.developer_updates
}

resource "discord_text_channel" "cloudflare_status" {
  name      = "cloudflare-status"
  position  = index(local.channel_order, "cloudflare_status")
  server_id = discord_server.server.id
  category  = discord_category_channel.third_parties.id
}

import {
  id = 1313493521755410443
  to = discord_text_channel.cloudflare_status
}

resource "discord_text_channel" "github_status" {
  name      = "github-status"
  topic     = "https://www.githubstatus.com"
  position  = index(local.channel_order, "github_status")
  server_id = discord_server.server.id
  category  = discord_category_channel.third_parties.id
}

import {
  id = 1240662502912692236
  to = discord_text_channel.github_status
}

resource "discord_text_channel" "github_issues_and_discussion" {
  name      = "github-issues-and-discussion"
  topic     = "New GitHub issue and discussion thread"
  position  = index(local.channel_order, "github_issues_and_discussion")
  server_id = discord_server.server.id
  category  = discord_category_channel.third_parties.id
}

import {
  id = 991483015958106202
  to = discord_text_channel.github_issues_and_discussion
}

resource "discord_text_channel" "github_pull_requests" {
  name      = "github-pull-requests"
  position  = index(local.channel_order, "github_pull_requests")
  server_id = discord_server.server.id
  category  = discord_category_channel.third_parties.id
}

import {
  id = 991483093179445350
  to = discord_text_channel.github_pull_requests
}

resource "discord_news_channel" "github_releases" {
  name      = "github-releases"
  position  = index(local.channel_order, "github_releases")
  server_id = discord_server.server.id
  category  = discord_category_channel.third_parties.id
}

import {
  id = 991477056791658567
  to = discord_news_channel.github_releases
}

resource "discord_text_channel" "bot_spam" {
  name                     = "bot-spam"
  position                 = index(local.channel_order, "bot_spam")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.off_topic.id
  sync_perms_with_category = false
}

import {
  id = 1159083520027787307
  to = discord_text_channel.bot_spam
}

resource "discord_text_channel" "emotes" {
  name                     = "emotes"
  position                 = index(local.channel_order, "emotes")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.off_topic.id
  sync_perms_with_category = false
}

import {
  id = 1287169306244943894
  to = discord_text_channel.emotes
}

resource "discord_text_channel" "off_topic" {
  name      = "off-topic"
  topic     = "Your retro chatroom with an Immich theme"
  position  = index(local.channel_order, "off_topic")
  server_id = discord_server.server.id
  category  = discord_category_channel.off_topic.id
}

import {
  id = 991643870523830382
  to = discord_text_channel.off_topic
}

resource "discord_voice_channel" "immich_voice" {
  name                     = "immich-voice"
  position                 = index(local.channel_order, "immich_voice")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.voice.id
  sync_perms_with_category = false
}

import {
  id = 1227374363611758714
  to = discord_voice_channel.immich_voice
}

resource "discord_voice_channel" "dev_voice" {
  name                     = "dev-voice"
  position                 = index(local.channel_order, "dev_voice")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.voice.id
  sync_perms_with_category = false
}

import {
  id = 1195047174652838131
  to = discord_voice_channel.dev_voice
}

resource "discord_voice_channel" "team_voice" {
  name                     = "team-voice"
  position                 = index(local.channel_order, "team_voice")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.voice.id
  sync_perms_with_category = false
}

import {
  id = 1330249756101840916
  to = discord_voice_channel.team_voice
}

resource "discord_voice_channel" "leadership_voice" {
  name                     = "leadership-voice"
  position                 = index(local.channel_order, "leadership_voice")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.voice.id
  sync_perms_with_category = false
}

import {
  id = 1194039173838016573
  to = discord_voice_channel.leadership_voice
}
