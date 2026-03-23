locals {
  channel_order = {
    # Top Level
    top_level = [
      "rules",
      "welcome",
      "announcements",
      "poll",
    ]
    # Immich
    immich = [
      "help_desk_support",
      "package_maintainers",
      "focus_discussion",
      "contributing",
      "translations",
      "immich",
      "merch",
    ]
    # Community
    community = [
      "imagegenius_aio",
      "immich_go",
      "immich_frame",
      "immich_kiosk",
      "immich_power_tools",
      "truenas",
      "unraid"
    ]
    # Support Crew
    support_crew = [
      "support_crew",
      "draft_announcements",
    ]
    # Development
    development = [
      "dev",
      "dev_off_topic",
      "dev_focus_topic",
    ]
    # Team
    team = [
      "team",
      "team_slop",
      "team_off_topic",
      "team_focus_topic",
      "team_pull_requests",
      "team_purchases",
      "team_alerts",
    ]
    # Yucca
    yucca = [
      "yucca",
      "yucca_off_topic",
      "yucca_focus_topic",
      "yucca_alerts",
      "yucca_alerts_testing",
      "yucca_alerts_dev",
    ]
    # Leadership
    leadership = [
      "leadership",
      "leadership_off_topic",
      "leadership_alerts",
      "leadership_focus_topic",
      "moderator_only",
    ]
    # Third Parties
    third_parties = [
      "developer_updates",
      "cloudflare_status",
      "github_status",
      "github_issues_and_discussion",
      "github_pull_requests",
      "github_releases",
    ]
    # Off Topic
    off_topic = [
      "bot_spam",
      "emotes",
      "off_topic",
    ]
    # Voice
    voice = [
      "immich_voice",
      "dev_voice",
      "team_voice",
      "team_voice_2",
      "yucca_voice",
      "leadership_voice",
    ]
    # Archive
    archive = [
      "dev_fosdem",
      "fosdem_2025",
      "dev_server",
      "conference_room",
      "branding",
      "dev_ml",
      "futo",
      "immich_nix",
      "dev_mobile",
      "dev_roles",
      "dev_security",
      "dev_ops",
      "futo_discussion_old",
      "dev_web",
      "dev_cli",
      "jasons_adventures_with_unraid_docker_and_networking",
      "build_status",
      "the_main_stage",
    ]
  }
}

data "discord_permission" "view_channel" {
  view_channel         = "allow"
  add_reactions        = "allow"
  use_external_emojis  = "allow"
  read_message_history = "allow"
  send_messages        = "deny"
}

data "discord_permission" "read_channel_write_threads" {
  allow_extends         = data.discord_permission.view_channel.allow_bits
  send_messages         = "deny"
  send_thread_messages  = "allow"
  create_public_threads = "allow"
}

data "discord_permission" "write_channel" {
  allow_extends             = data.discord_permission.read_channel_write_threads.allow_bits
  send_messages             = "allow"
  embed_links               = "allow"
  attach_files              = "allow"
  use_external_stickers     = "allow"
  send_voice_messages       = "allow"
  send_polls                = "allow"
  start_embedded_activities = "allow"
  connect                   = "allow"
  speak                     = "allow"
  stream                    = "allow"
  use_soundboard            = "allow"
  use_external_sounds       = "allow"
  use_vad                   = "allow"
  use_application_commands  = "allow"
  use_external_apps         = "allow"
  request_to_speak          = "allow"
}

module "everyone_channels_read" {
  source = "./channel-perms"
  channels = {
    rules                        = discord_text_channel.rules.id
    welcome                      = discord_text_channel.welcome.id
    developer_updates            = discord_text_channel.developer_updates.id
    cloudflare_status            = discord_text_channel.cloudflare_status.id
    github_status                = discord_text_channel.github_status.id
    github_issues_and_discussion = discord_text_channel.github_issues_and_discussion.id
    github_pull_requests         = discord_text_channel.github_pull_requests.id
    fosdem_2025                  = discord_text_channel.fosdem_2025.id
    immich_nix                   = discord_text_channel.immich_nix.id
  }
  roles = {
    everyone = discord_role_everyone.everyone.id
  }
  allow  = data.discord_permission.view_channel.allow_bits
  deny   = data.discord_permission.view_channel.deny_bits
  public = true
}

module "everyone_channels_write_threads" {
  source = "./channel-perms"
  channels = {
    announcements   = discord_news_channel.announcements.id
    poll            = discord_news_channel.poll.id
    github_releases = discord_news_channel.github_releases.id
  }
  roles = {
    everyone = discord_role_everyone.everyone.id
  }
  allow  = data.discord_permission.read_channel_write_threads.allow_bits
  deny   = data.discord_permission.read_channel_write_threads.deny_bits
  public = true
}

module "everyone_channels_write" {
  source = "./channel-perms"
  channels = {
    help_desk_support  = discord_forum_channel.help_desk_support.id
    focus_discussion   = discord_forum_channel.focus_discussion.id
    contributing       = discord_text_channel.contributing.id
    translations       = discord_text_channel.translations.id
    immich             = discord_text_channel.immich.id
    merch              = discord_text_channel.merch.id
    imagegenius_aio    = discord_text_channel.imagegenius_aio.id
    immich_go          = discord_text_channel.immich_go.id
    immich_frame       = discord_text_channel.immich_frame.id
    immich_kiosk       = discord_text_channel.immich_kiosk.id
    immich_power_tools = discord_text_channel.immich_power_tools.id
    truenas            = discord_text_channel.truenas.id
    unraid             = discord_text_channel.unraid.id
    off_topic          = discord_text_channel.off_topic.id
    immich_voice       = discord_voice_channel.immich_voice.id
  }
  roles = {
    everyone = discord_role_everyone.everyone.id
  }
  allow  = data.discord_permission.write_channel.allow_bits
  deny   = data.discord_permission.write_channel.deny_bits
  public = true
}

module "support_channels_write" {
  source = "./channel-perms"
  channels = {
    support_crew        = discord_text_channel.support_crew.id
    draft_announcements = discord_forum_channel.draft_announcements.id
  }
  roles = {
    support_crew = discord_role.support_crew.id
    contributor  = discord_role.contributor.id
  }
  allow       = data.discord_permission.write_channel.allow_bits
  everyone_id = discord_role_everyone.everyone.id
  public      = false
}

module "package_maintainers_write" {
  source = "./channel-perms"
  channels = {
    package_maintainers = discord_text_channel.package_maintainers.id
  }
  roles = {
    package_maintainer = discord_role.package_maintainer.id
    contributor        = discord_role.contributor.id
  }
  allow       = data.discord_permission.write_channel.allow_bits
  everyone_id = discord_role_everyone.everyone.id
  public      = false
}

module "contributor_channels_read" {
  source = "./channel-perms"
  channels = {
    dev_fosdem      = discord_text_channel.dev_fosdem.id
    dev_server      = discord_text_channel.dev_server.id
    conference_room = discord_text_channel.conference_room.id
    branding        = discord_text_channel.branding.id
    dev_ml          = discord_text_channel.dev_ml.id
    dev_mobile      = discord_text_channel.dev_mobile.id
    dev_roles       = discord_text_channel.dev_roles.id
    dev_security    = discord_text_channel.dev_security.id
    dev_ops         = discord_text_channel.dev_ops.id
    dev_web         = discord_text_channel.dev_web.id
    dev_cli         = discord_text_channel.dev_cli.id
  }
  roles = {
    contributor = discord_role.contributor.id
  }
  allow       = data.discord_permission.view_channel.allow_bits
  deny        = data.discord_permission.view_channel.deny_bits
  everyone_id = discord_role_everyone.everyone.id
  public      = false
}

module "contributor_channels_write" {
  source = "./channel-perms"
  channels = {
    dev             = discord_text_channel.dev.id
    dev_off_topic   = discord_text_channel.dev_off_topic.id
    dev_focus_topic = discord_forum_channel.dev_focus_topic.id
    dev_voice       = discord_voice_channel.dev_voice.id
  }
  roles = {
    contributor = discord_role.contributor.id
  }
  allow       = data.discord_permission.write_channel.allow_bits
  everyone_id = discord_role_everyone.everyone.id
  public      = false
}

module "futo_channels_write" {
  source = "./channel-perms"
  channels = {
    team              = discord_text_channel.team.id
    team_focus_topic  = discord_forum_channel.team_focus_topic.id
    team_purchases    = discord_text_channel.team_purchases.id
    yucca             = discord_text_channel.yucca.id
    yucca_focus_topic = discord_forum_channel.yucca_focus_topic.id
    yucca_alerts      = discord_text_channel.yucca_alerts.id
  }
  roles = {
    futo = discord_role.futo.id
  }
  allow       = data.discord_permission.write_channel.allow_bits
  everyone_id = discord_role_everyone.everyone.id
  public      = false
}

module "team_channels_read" {
  source = "./channel-perms"
  channels = {
    futo                = discord_text_channel.futo.id
    futo_discussion_old = discord_text_channel.futo_discussion_old.id
  }
  roles = {
    team = discord_role.team.id
  }
  allow       = data.discord_permission.view_channel.allow_bits
  deny        = data.discord_permission.view_channel.deny_bits
  everyone_id = discord_role_everyone.everyone.id
  public      = false
}

module "team_channels_write" {
  source = "./channel-perms"
  channels = {
    team                 = discord_text_channel.team.id
    team_slop            = discord_text_channel.team_slop.id
    team_off_topic       = discord_text_channel.team_off_topic.id
    team_focus_topic     = discord_forum_channel.team_focus_topic.id
    team_pull_requests   = discord_forum_channel.team_pull_requests.id,
    team_purchases       = discord_text_channel.team_purchases.id
    team_alerts          = discord_text_channel.team_alerts.id
    bot_spam             = discord_text_channel.bot_spam.id
    emotes               = discord_text_channel.emotes.id
    team_voice           = discord_voice_channel.team_voice.id
    team_voice_2         = discord_voice_channel.team_voice_2.id
    yucca                = discord_text_channel.yucca.id
    yucca_off_topic      = discord_text_channel.yucca_off_topic.id
    yucca_focus_topic    = discord_forum_channel.yucca_focus_topic.id
    yucca_alerts         = discord_text_channel.yucca_alerts.id
    yucca_alerts_testing = discord_text_channel.yucca_alerts_testing.id
    yucca_alerts_dev     = discord_text_channel.yucca_alerts_dev.id
    yucca_voice          = discord_voice_channel.yucca_voice.id
  }
  roles = {
    team = discord_role.team.id
  }
  allow       = data.discord_permission.write_channel.allow_bits
  everyone_id = discord_role_everyone.everyone.id
  public      = false
}

module "admin_channels_write" {
  source = "./channel-perms"
  channels = {
    leadership                                          = discord_text_channel.leadership.id
    leadership_off_topic                                = discord_text_channel.leadership_off_topic.id
    leadership_alerts                                   = discord_text_channel.leadership_alerts.id
    leadership_focus_topic                              = discord_forum_channel.leadership_focus_topic.id
    moderator_only                                      = discord_text_channel.moderator_only.id
    leadership_voice                                    = discord_voice_channel.leadership_voice.id
    jasons_adventures_with_unraid_docker_and_networking = discord_text_channel.jasons_adventures_with_unraid_docker_and_networking.id
    build_status                                        = discord_text_channel.build_status.id
  }
  roles = {
    admin = discord_role.admin.id
  }
  allow       = data.discord_permission.write_channel.allow_bits
  everyone_id = discord_role_everyone.everyone.id
  public      = false
}

module "admin_channels_write_public" {
  source = "./channel-perms"
  channels = {
    rules         = discord_text_channel.rules.id
    welcome       = discord_text_channel.welcome.id
    announcements = discord_news_channel.announcements.id
    poll          = discord_news_channel.poll.id
  }
  roles = {
    admin = discord_role.admin.id
  }
  allow  = data.discord_permission.write_channel.allow_bits
  public = true
}

resource "discord_text_channel" "rules" {
  name                     = "rules"
  position                 = index(local.channel_order.top_level, "rules")
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "welcome" {
  name                     = "welcome"
  position                 = index(local.channel_order.top_level, "welcome")
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_news_channel" "announcements" {
  name                     = "announcements"
  position                 = index(local.channel_order.top_level, "announcements")
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_news_channel" "poll" {
  name                     = "poll"
  topic                    = "Community driven choices"
  position                 = index(local.channel_order.top_level, "poll")
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_forum_channel" "help_desk_support" {
  name                     = "help-desk-support"
  position                 = index(local.channel_order.immich, "help_desk_support")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.immich.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

import {
  id = 1049703391762321418
  to = discord_forum_channel.help_desk_support
}

resource "discord_text_channel" "support_crew" {
  name                     = "support-crew"
  position                 = index(local.channel_order.support_crew, "support_crew")
  category                 = discord_category_channel.support_crew.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "package_maintainers" {
  name                     = "package-maintainers"
  position                 = index(local.channel_order.immich, "package_maintainers")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.immich.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_forum_channel" "focus_discussion" {
  name                     = "focus-discussion"
  position                 = index(local.channel_order.immich, "focus_discussion")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.immich.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

import {
  id = 1026327300284887111
  to = discord_forum_channel.focus_discussion
}

resource "discord_text_channel" "contributing" {
  name                     = "contributing"
  topic                    = "Discuss technical topics on contributing to the Immich codebase. Not for support/troubleshooting."
  position                 = index(local.channel_order.immich, "contributing")
  category                 = discord_category_channel.immich.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "translations" {
  name                     = "translations"
  topic                    = "https://hosted.weblate.org/projects/immich/immich/"
  position                 = index(local.channel_order.immich, "translations")
  category                 = discord_category_channel.immich.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "immich" {
  name                     = "immich"
  topic                    = "General discussion about everything Immich"
  position                 = index(local.channel_order.immich, "immich")
  category                 = discord_category_channel.immich.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "merch" {
  name                     = "merch"
  topic                    = "https://immich.store"
  position                 = index(local.channel_order.immich, "merch")
  category                 = discord_category_channel.immich.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "imagegenius_aio" {
  name                     = "imagegenius-aio"
  topic                    = "Discussion channel for the all-in-one image - https://github.com/imagegenius/docker-immich"
  position                 = index(local.channel_order.community, "imagegenius_aio")
  category                 = discord_category_channel.community.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "immich_go" {
  name                     = "immich-go"
  topic                    = "Discussion channel for the immich-go upload tool - https://github.com/simulot/immich-go"
  position                 = index(local.channel_order.community, "immich_go")
  category                 = discord_category_channel.community.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "immich_frame" {
  name                     = "immich-frame"
  topic                    = "Discussion for the https://github.com/immichFrame/ImmichFrame project"
  position                 = index(local.channel_order.community, "immich_frame")
  category                 = discord_category_channel.community.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "immich_kiosk" {
  name                     = "immich-kiosk"
  topic                    = "https://github.com/damongolding/immich-kiosk"
  position                 = index(local.channel_order.community, "immich_kiosk")
  category                 = discord_category_channel.community.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "immich_power_tools" {
  name                     = "immich-power-tools"
  topic                    = "Discussion channel for the immich power tools — https://github.com/varun-raj/immich-power-tools"
  position                 = index(local.channel_order.community, "immich_power_tools")
  category                 = discord_category_channel.community.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "truenas" {
  name                     = "truenas"
  topic                    = "Discussion channel for the truenas immich app"
  position                 = index(local.channel_order.community, "truenas")
  category                 = discord_category_channel.community.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "unraid" {
  name                     = "unraid"
  topic                    = "Discussion channel for Immich on unraid"
  position                 = index(local.channel_order.community, "unraid")
  category                 = discord_category_channel.community.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "dev" {
  name                     = "dev"
  position                 = index(local.channel_order.development, "dev")
  category                 = discord_category_channel.development.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "dev_off_topic" {
  name                     = "dev-off-topic"
  topic                    = "Development parking lot conversation"
  position                 = index(local.channel_order.development, "dev_off_topic")
  category                 = discord_category_channel.development.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_forum_channel" "draft_announcements" {
  name                     = "draft-announcements"
  position                 = index(local.channel_order.support_crew, "draft_announcements")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.support_crew.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

import {
  id = 1073000522338017381
  to = discord_forum_channel.draft_announcements
}

resource "discord_forum_channel" "dev_focus_topic" {
  name                     = "dev-focus-topic"
  position                 = index(local.channel_order.development, "dev_focus_topic")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.development.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

import {
  id = 1045707766754451486
  to = discord_forum_channel.dev_focus_topic
}

resource "discord_text_channel" "team" {
  name                     = "team"
  position                 = index(local.channel_order.team, "team")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.team.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "team_slop" {
  name                     = "team-slop"
  position                 = index(local.channel_order.team, "team_slop")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.team.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "team_off_topic" {
  name                     = "team-off-topic"
  position                 = index(local.channel_order.team, "team_off_topic")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.team.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_forum_channel" "team_focus_topic" {
  name                     = "team-focus-topic"
  position                 = index(local.channel_order.team, "team_focus_topic")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.team.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

import {
  id = 1330248543721754746
  to = discord_forum_channel.team_focus_topic
}

resource "discord_forum_channel" "team_pull_requests" {
  name                     = "team-pull-requests"
  position                 = index(local.channel_order.team, "team_pull_requests")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.team.id
  sync_perms_with_category = false
}

resource "discord_text_channel" "team_alerts" {
  name                     = "team-alerts"
  position                 = index(local.channel_order.team, "team_alerts")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.team.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "team_purchases" {
  name                     = "team-purchases"
  position                 = index(local.channel_order.team, "team_purchases")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.team.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "yucca" {
  name                     = "yucca"
  position                 = index(local.channel_order.yucca, "yucca")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.yucca.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "yucca_off_topic" {
  name                     = "yucca-off-topic"
  position                 = index(local.channel_order.yucca, "yucca_off_topic")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.yucca.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_forum_channel" "yucca_focus_topic" {
  name                     = "yucca-focus-topic"
  position                 = index(local.channel_order.yucca, "yucca_focus_topic")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.yucca.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "yucca_alerts" {
  name                     = "yucca-alerts"
  position                 = index(local.channel_order.yucca, "yucca_alerts")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.yucca.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "yucca_alerts_testing" {
  name                     = "yucca-alerts-testing"
  position                 = index(local.channel_order.yucca, "yucca_alerts_testing")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.yucca.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "yucca_alerts_dev" {
  name                     = "yucca-alerts-dev"
  position                 = index(local.channel_order.yucca, "yucca_alerts_dev")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.yucca.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "leadership" {
  name                     = "leadership"
  topic                    = "The place we make decisions that we know nothing about"
  position                 = index(local.channel_order.leadership, "leadership")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.leadership.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "leadership_off_topic" {
  name                     = "leadership-off-topic"
  position                 = index(local.channel_order.leadership, "leadership_off_topic")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.leadership.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "leadership_alerts" {
  name                     = "leadership-alerts"
  position                 = index(local.channel_order.leadership, "leadership_alerts")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.leadership.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_forum_channel" "leadership_focus_topic" {
  name                     = "leadership-focus-topic"
  position                 = index(local.channel_order.leadership, "leadership_focus_topic")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.leadership.id
  sync_perms_with_category = false
}

import {
  id = 1229454284479795291
  to = discord_forum_channel.leadership_focus_topic
}

resource "discord_text_channel" "moderator_only" {
  name                     = "moderator-only"
  position                 = index(local.channel_order.leadership, "moderator_only")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.leadership.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "developer_updates" {
  name                     = "developer-updates"
  position                 = index(local.channel_order.third_parties, "developer_updates")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.third_parties.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "cloudflare_status" {
  name                     = "cloudflare-status"
  position                 = index(local.channel_order.third_parties, "cloudflare_status")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.third_parties.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "github_status" {
  name                     = "github-status"
  topic                    = "https://www.githubstatus.com"
  position                 = index(local.channel_order.third_parties, "github_status")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.third_parties.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "github_issues_and_discussion" {
  name                     = "github-issues-and-discussion"
  topic                    = "New GitHub issue and discussion thread"
  position                 = index(local.channel_order.third_parties, "github_issues_and_discussion")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.third_parties.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "github_pull_requests" {
  name                     = "github-pull-requests"
  position                 = index(local.channel_order.third_parties, "github_pull_requests")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.third_parties.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_news_channel" "github_releases" {
  name                     = "github-releases"
  position                 = index(local.channel_order.third_parties, "github_releases")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.third_parties.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "bot_spam" {
  name                     = "bot-spam"
  position                 = index(local.channel_order.off_topic, "bot_spam")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.off_topic.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "emotes" {
  name                     = "emotes"
  position                 = index(local.channel_order.off_topic, "emotes")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.off_topic.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "off_topic" {
  name                     = "off-topic"
  topic                    = "Your retro chatroom with an Immich theme"
  position                 = index(local.channel_order.off_topic, "off_topic")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.off_topic.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_voice_channel" "immich_voice" {
  name                     = "immich-voice"
  position                 = index(local.channel_order.voice, "immich_voice")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.voice.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_voice_channel" "dev_voice" {
  name                     = "dev-voice"
  position                 = index(local.channel_order.voice, "dev_voice")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.voice.id
  bitrate                  = var.env == "prod" ? 384000 : 64000
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_voice_channel" "team_voice" {
  name                     = "team-voice"
  position                 = index(local.channel_order.voice, "team_voice")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.voice.id
  bitrate                  = var.env == "prod" ? 384000 : 64000
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_voice_channel" "team_voice_2" {
  name                     = "team-voice-2"
  position                 = index(local.channel_order.voice, "team_voice_2")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.voice.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_voice_channel" "yucca_voice" {
  name                     = "yucca-voice"
  position                 = index(local.channel_order.voice, "yucca_voice")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.voice.id
  bitrate                  = var.env == "prod" ? 384000 : 64000
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_voice_channel" "leadership_voice" {
  name                     = "leadership-voice"
  position                 = index(local.channel_order.voice, "leadership_voice")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.voice.id
  bitrate                  = var.env == "prod" ? 384000 : 64000
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "dev_fosdem" {
  name                     = "dev-fosdem"
  position                 = index(local.channel_order.archive, "dev_fosdem")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.archive.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

import {
  id = 1291108934861586492
  to = discord_text_channel.dev_fosdem
}

resource "discord_text_channel" "fosdem_2025" {
  name                     = "fosdem-2025"
  position                 = index(local.channel_order.archive, "fosdem_2025")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.archive.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

import {
  id = 1334949885442654248
  to = discord_text_channel.fosdem_2025
}

resource "discord_text_channel" "dev_server" {
  name                     = "dev-server"
  position                 = index(local.channel_order.archive, "dev_server")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.archive.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

import {
  id = 1155894065062236160
  to = discord_text_channel.dev_server
}

resource "discord_text_channel" "conference_room" {
  name                     = "conference-room"
  position                 = index(local.channel_order.archive, "conference_room")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.archive.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

import {
  id = 1206801539470069810
  to = discord_text_channel.conference_room
}

resource "discord_text_channel" "branding" {
  name                     = "branding"
  position                 = index(local.channel_order.archive, "branding")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.archive.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

import {
  id = 1215143314358009866
  to = discord_text_channel.branding
}

resource "discord_text_channel" "dev_ml" {
  name                     = "dev-ml"
  position                 = index(local.channel_order.archive, "dev_ml")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.archive.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

import {
  id = 1175513104877101078
  to = discord_text_channel.dev_ml
}

resource "discord_text_channel" "futo" {
  name                     = "futo"
  position                 = index(local.channel_order.archive, "futo")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.archive.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

import {
  id = 1208144146825748491
  to = discord_text_channel.futo
}

resource "discord_text_channel" "immich_nix" {
  name                     = "immich-nix"
  position                 = index(local.channel_order.archive, "immich_nix")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.archive.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

import {
  id = 1288786177952059435
  to = discord_text_channel.immich_nix
}

resource "discord_text_channel" "dev_mobile" {
  name                     = "dev-mobile"
  position                 = index(local.channel_order.archive, "dev_mobile")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.archive.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

import {
  id = 1069026079349669951
  to = discord_text_channel.dev_mobile
}

resource "discord_text_channel" "dev_roles" {
  name                     = "dev-roles"
  position                 = index(local.channel_order.archive, "dev_roles")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.archive.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

import {
  id = 1196526624812839034
  to = discord_text_channel.dev_roles
}

resource "discord_text_channel" "dev_security" {
  name                     = "dev-security"
  position                 = index(local.channel_order.archive, "dev_security")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.archive.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

import {
  id = 1020479445167001650
  to = discord_text_channel.dev_security
}

resource "discord_text_channel" "dev_ops" {
  name                     = "dev-ops"
  position                 = index(local.channel_order.archive, "dev_ops")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.archive.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

import {
  id = 1176633064462487686
  to = discord_text_channel.dev_ops
}

resource "discord_text_channel" "futo_discussion_old" {
  name                     = "futo-discussion-old"
  position                 = index(local.channel_order.archive, "futo_discussion_old")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.archive.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

import {
  id = 1238236317729554523
  to = discord_text_channel.futo_discussion_old
}

resource "discord_text_channel" "dev_web" {
  name                     = "dev-web"
  position                 = index(local.channel_order.archive, "dev_web")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.archive.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

import {
  id = 1169697266806820974
  to = discord_text_channel.dev_web
}

resource "discord_text_channel" "dev_cli" {
  name                     = "dev-cli"
  position                 = index(local.channel_order.archive, "dev_cli")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.archive.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

import {
  id = 1175153422866059329
  to = discord_text_channel.dev_cli
}

resource "discord_text_channel" "jasons_adventures_with_unraid_docker_and_networking" {
  name                     = "jasons-adventures-with-unraid-docker-and-networking"
  position                 = index(local.channel_order.archive, "jasons_adventures_with_unraid_docker_and_networking")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.archive.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

import {
  id = 1230989262325813270
  to = discord_text_channel.jasons_adventures_with_unraid_docker_and_networking
}

resource "discord_text_channel" "build_status" {
  name                     = "build-status"
  position                 = index(local.channel_order.archive, "build_status")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.archive.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

import {
  id = 981216275210584134
  to = discord_text_channel.build_status
}
