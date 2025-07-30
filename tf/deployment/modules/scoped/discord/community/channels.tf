locals {
  channel_order = [
    # No Category - Top Level
    "rules",
    "welcome",
    "announcements",
    "poll",
    # Immich Category
    "help_desk_support",
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
    # Support Crew Category
    "support_crew",
    "draft_announcements",
    # Development Category
    "dev",
    "dev_off_topic",
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
    "team_voice_2",
    "leadership_voice",
    # Archive
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
    "the_main_stage"
  ]
  forum_channels = {
    help_desk_support      = { prod = 1049703391762321418, dev = 1369634313804709919 },
    focus_discussion       = { prod = 1026327300284887111, dev = 1369634360923394100 },
    dev_focus_topic        = { prod = 1045707766754451486, dev = 1369634655103619073 },
    draft_announcements    = { prod = 1073000522338017381, dev = 1369634690172063825 },
    team_focus_topic       = { prod = 1330248543721754746, dev = 1369634517366607883 },
    leadership_focus_topic = { prod = 1229454284479795291, dev = 1369634453672169532 },
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
  channel_ids = [
    discord_text_channel.rules.id,
    discord_text_channel.welcome.id,
    discord_text_channel.developer_updates.id,
    discord_text_channel.cloudflare_status.id,
    discord_text_channel.github_status.id,
    discord_text_channel.github_issues_and_discussion.id,
    discord_text_channel.github_pull_requests.id,
    discord_text_channel.fosdem_2025.id,
    discord_text_channel.immich_nix.id,
  ]
  role_ids = [discord_role_everyone.everyone.id]
  allow    = data.discord_permission.view_channel.allow_bits
  deny     = data.discord_permission.view_channel.deny_bits
  public   = true
}

module "everyone_channels_write_threads" {
  source = "./channel-perms"
  channel_ids = [
    discord_news_channel.announcements.id,
    discord_news_channel.poll.id,
    discord_news_channel.github_releases.id,
  ]
  role_ids = [discord_role_everyone.everyone.id]
  allow    = data.discord_permission.read_channel_write_threads.allow_bits
  deny     = data.discord_permission.read_channel_write_threads.deny_bits
  public   = true
}

module "everyone_channels_write" {
  source = "./channel-perms"
  channel_ids = [
    local.forum_channels.help_desk_support[var.env],
    local.forum_channels.focus_discussion[var.env],
    discord_text_channel.contributing.id,
    discord_text_channel.translations.id,
    discord_text_channel.immich.id,
    discord_text_channel.merch.id,
    discord_text_channel.imagegenius_aio.id,
    discord_text_channel.immich_go.id,
    discord_text_channel.immich_frame.id,
    discord_text_channel.immich_kiosk.id,
    discord_text_channel.immich_power_tools.id,
    discord_text_channel.truenas.id,
    discord_text_channel.unraid.id,
    discord_text_channel.off_topic.id,
    discord_voice_channel.immich_voice.id,
  ]
  role_ids = [discord_role_everyone.everyone.id]
  allow    = data.discord_permission.write_channel.allow_bits
  deny     = data.discord_permission.write_channel.deny_bits
  public   = true
}

module "support_channels_write" {
  source = "./channel-perms"
  channel_ids = [
    discord_text_channel.support_crew.id,
    local.forum_channels.draft_announcements[var.env]
  ]
  role_ids    = [discord_role.support_crew.id, discord_role.contributor.id]
  allow       = data.discord_permission.write_channel.allow_bits
  everyone_id = discord_role_everyone.everyone.id
  public      = false
}

module "package_maintainers_write" {
  source = "./channel-perms"
  channel_ids = [
    discord_text_channel.package_maintainers.id
  ]
  role_ids    = [discord_role.package_maintainer.id, discord_role.contributor.id]
  allow       = data.discord_permission.write_channel.allow_bits
  everyone_id = discord_role_everyone.everyone.id
  public      = false
}

module "contributor_channels_read" {
  source = "./channel-perms"
  channel_ids = [
    discord_text_channel.dev_fosdem.id,
    discord_text_channel.dev_server.id,
    discord_text_channel.conference_room.id,
    discord_text_channel.branding.id,
    discord_text_channel.dev_ml.id,
    discord_text_channel.dev_mobile.id,
    discord_text_channel.dev_roles.id,
    discord_text_channel.dev_security.id,
    discord_text_channel.dev_ops.id,
    discord_text_channel.dev_web.id,
    discord_text_channel.dev_cli.id,
  ]
  role_ids    = [discord_role.contributor.id]
  allow       = data.discord_permission.view_channel.allow_bits
  deny        = data.discord_permission.view_channel.deny_bits
  everyone_id = discord_role_everyone.everyone.id
  public      = false
}

module "contributor_channels_write" {
  source = "./channel-perms"
  channel_ids = [
    discord_text_channel.dev.id,
    discord_text_channel.dev_off_topic.id,
    local.forum_channels.dev_focus_topic[var.env],
    discord_voice_channel.dev_voice.id,
  ]
  role_ids    = [discord_role.contributor.id]
  allow       = data.discord_permission.write_channel.allow_bits
  everyone_id = discord_role_everyone.everyone.id
  public      = false
}

module "team_channels_read" {
  source = "./channel-perms"
  channel_ids = [
    discord_text_channel.futo.id,
    discord_text_channel.futo_discussion_old.id,
  ]
  role_ids    = [discord_role.team.id]
  allow       = data.discord_permission.view_channel.allow_bits
  deny        = data.discord_permission.view_channel.deny_bits
  everyone_id = discord_role_everyone.everyone.id
  public      = false
}

module "team_channels_write" {
  source = "./channel-perms"
  channel_ids = [
    discord_text_channel.team.id,
    discord_text_channel.team_off_topic.id,
    local.forum_channels.team_focus_topic[var.env],
    discord_text_channel.team_purchases.id,
    discord_text_channel.team_alerts.id,
    discord_text_channel.bot_spam.id,
    discord_text_channel.emotes.id,
    discord_voice_channel.team_voice.id,
    discord_voice_channel.team_voice_2.id,
  ]
  role_ids    = [discord_role.team.id]
  allow       = data.discord_permission.write_channel.allow_bits
  everyone_id = discord_role_everyone.everyone.id
  public      = false
}

module "admin_channels_write" {
  source = "./channel-perms"
  channel_ids = [
    discord_text_channel.leadership.id,
    discord_text_channel.leadership_off_topic.id,
    discord_text_channel.leadership_alerts.id,
    local.forum_channels.leadership_focus_topic[var.env],
    discord_text_channel.moderator_only.id,
    discord_voice_channel.leadership_voice.id,
    discord_text_channel.jasons_adventures_with_unraid_docker_and_networking.id,
    discord_text_channel.build_status.id,
  ]
  role_ids    = [discord_role.admin.id]
  allow       = data.discord_permission.write_channel.allow_bits
  everyone_id = discord_role_everyone.everyone.id
  public      = false
}

module "admin_channels_write_public" {
  source = "./channel-perms"
  channel_ids = [
    discord_text_channel.rules.id,
    discord_text_channel.welcome.id,
    discord_news_channel.announcements.id,
    discord_news_channel.poll.id,
  ]
  role_ids = [discord_role.admin.id]
  allow    = data.discord_permission.write_channel.allow_bits
  public   = true
}

resource "discord_text_channel" "rules" {
  name                     = "rules"
  position                 = index(local.channel_order, "rules")
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "welcome" {
  name                     = "welcome"
  position                 = index(local.channel_order, "welcome")
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_news_channel" "announcements" {
  name                     = "announcements"
  position                 = index(local.channel_order, "announcements")
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_news_channel" "poll" {
  name                     = "poll"
  topic                    = "Community driven choices"
  position                 = index(local.channel_order, "poll")
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
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
  category                 = discord_category_channel.support_crew.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "package_maintainers" {
  name                     = "package-maintainers"
  position                 = index(local.channel_order, "package_maintainers")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.immich.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
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
  name                     = "contributing"
  topic                    = "Discuss technical topics on contributing to the Immich codebase. Not for support/troubleshooting."
  position                 = index(local.channel_order, "contributing")
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
  position                 = index(local.channel_order, "translations")
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
  position                 = index(local.channel_order, "immich")
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
  position                 = index(local.channel_order, "merch")
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
  position                 = index(local.channel_order, "imagegenius_aio")
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
  position                 = index(local.channel_order, "immich_go")
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
  position                 = index(local.channel_order, "immich_frame")
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
  position                 = index(local.channel_order, "immich_kiosk")
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
  position                 = index(local.channel_order, "immich_power_tools")
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
  position                 = index(local.channel_order, "truenas")
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
  position                 = index(local.channel_order, "unraid")
  category                 = discord_category_channel.community.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "dev" {
  name                     = "dev"
  position                 = index(local.channel_order, "dev")
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
  position                 = index(local.channel_order, "dev_off_topic")
  category                 = discord_category_channel.development.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

# resource "discord_forum_channel" "draft_announcements" {
#   name      = "draft-announcements"
#   position  = index(local.channel_order, "draft_announcements")
#   server_id = discord_server.server.id
#   category  = discord_category_channel.support_crew.id
# }
#
# import {
#   id = 1073000522338017381
#   to = discord_forum_channel.draft_announcements
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
  name                     = "team"
  position                 = index(local.channel_order, "team")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.team.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "team_off_topic" {
  name                     = "team-off-topic"
  position                 = index(local.channel_order, "team_off_topic")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.team.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
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
  name                     = "team-alerts"
  position                 = index(local.channel_order, "team_alerts")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.team.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "team_purchases" {
  name                     = "team-purchases"
  position                 = index(local.channel_order, "team_purchases")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.team.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "leadership" {
  name                     = "leadership"
  topic                    = "The place we make decisions that we know nothing about"
  position                 = index(local.channel_order, "leadership")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.leadership.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "leadership_off_topic" {
  name                     = "leadership-off-topic"
  position                 = index(local.channel_order, "leadership_off_topic")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.leadership.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "leadership_alerts" {
  name                     = "leadership-alerts"
  position                 = index(local.channel_order, "leadership_alerts")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.leadership.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
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
  name                     = "moderator-only"
  position                 = index(local.channel_order, "moderator_only")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.leadership.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "developer_updates" {
  name                     = "developer-updates"
  position                 = index(local.channel_order, "developer_updates")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.third_parties.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "cloudflare_status" {
  name                     = "cloudflare-status"
  position                 = index(local.channel_order, "cloudflare_status")
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
  position                 = index(local.channel_order, "github_status")
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
  position                 = index(local.channel_order, "github_issues_and_discussion")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.third_parties.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "github_pull_requests" {
  name                     = "github-pull-requests"
  position                 = index(local.channel_order, "github_pull_requests")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.third_parties.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_news_channel" "github_releases" {
  name                     = "github-releases"
  position                 = index(local.channel_order, "github_releases")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.third_parties.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "bot_spam" {
  name                     = "bot-spam"
  position                 = index(local.channel_order, "bot_spam")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.off_topic.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "emotes" {
  name                     = "emotes"
  position                 = index(local.channel_order, "emotes")
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
  position                 = index(local.channel_order, "off_topic")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.off_topic.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_voice_channel" "immich_voice" {
  name                     = "immich-voice"
  position                 = index(local.channel_order, "immich_voice")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.voice.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_voice_channel" "dev_voice" {
  name                     = "dev-voice"
  position                 = index(local.channel_order, "dev_voice")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.voice.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_voice_channel" "team_voice" {
  name                     = "team-voice"
  position                 = index(local.channel_order, "team_voice")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.voice.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_voice_channel" "team_voice_2" {
  name                     = "team-voice-2"
  position                 = index(local.channel_order, "team_voice_2")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.voice.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_voice_channel" "leadership_voice" {
  name                     = "leadership-voice"
  position                 = index(local.channel_order, "leadership_voice")
  server_id                = discord_server.server.id
  category                 = discord_category_channel.voice.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "dev_fosdem" {
  name                     = "dev-fosdem"
  position                 = index(local.channel_order, "dev_fosdem")
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
  position                 = index(local.channel_order, "fosdem_2025")
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
  position                 = index(local.channel_order, "dev_server")
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
  position                 = index(local.channel_order, "conference_room")
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
  position                 = index(local.channel_order, "branding")
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
  position                 = index(local.channel_order, "dev_ml")
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
  position                 = index(local.channel_order, "futo")
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
  position                 = index(local.channel_order, "immich_nix")
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
  position                 = index(local.channel_order, "dev_mobile")
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
  position                 = index(local.channel_order, "dev_roles")
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
  position                 = index(local.channel_order, "dev_security")
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
  position                 = index(local.channel_order, "dev_ops")
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
  position                 = index(local.channel_order, "futo_discussion_old")
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
  position                 = index(local.channel_order, "dev_web")
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
  position                 = index(local.channel_order, "dev_cli")
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
  position                 = index(local.channel_order, "jasons_adventures_with_unraid_docker_and_networking")
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
  position                 = index(local.channel_order, "build_status")
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
