locals {
  channel_order = {
    top_level = [
      "rules",
      "welcome",
      "announcements",
    ]
    futo = [
      "futo",
    ]
    projects = [
      "fcast",
      "fubs",
      "futo_keyboard",
      "futo_voice",
      "grayjay",
      "immich",
      "live_captions",
      "polycentric",
      "ret",
    ]
    team = [
      "team",
      "server_setup",
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

moved {
  from = module.everyone_project_channels_read
  to   = module.everyone_channels_read
}

moved {
  from = module.everyone_project_channels_write
  to   = module.everyone_channels_write
}

moved {
  from = module.everyone_channels_write.discord_channel_permission.permissions["everyone/general"]
  to   = module.everyone_channels_read.discord_channel_permission.permissions["everyone/welcome"]
}

module "everyone_channels_read" {
  source = "./channel-perms"
  channels = {
    rules         = discord_text_channel.rules.id
    welcome       = discord_text_channel.welcome.id
    futo_keyboard = discord_text_channel.futo_keyboard.id
    immich        = discord_text_channel.immich.id
    futo_voice    = discord_text_channel.futo_voice.id
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
    announcements = discord_text_channel.announcements.id
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
    futo          = discord_text_channel.futo.id
    grayjay       = discord_text_channel.grayjay.id
    polycentric   = discord_text_channel.polycentric.id
    fcast         = discord_text_channel.fcast.id
    live_captions = discord_text_channel.live_captions.id
    fubs          = discord_text_channel.fubs.id
    ret           = discord_text_channel.ret.id
  }
  roles = {
    everyone = discord_role_everyone.everyone.id
  }
  allow  = data.discord_permission.write_channel.allow_bits
  deny   = data.discord_permission.write_channel.deny_bits
  public = true
}

module "futo_channels_write" {
  source = "./channel-perms"
  channels = {
    team         = discord_text_channel.team.id
    server_setup = discord_text_channel.server_setup.id
  }
  roles = {
    futo = discord_role.futo.id
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
    announcements = discord_text_channel.announcements.id
  }
  roles = {
    admin = discord_role.admin.id
  }
  allow  = data.discord_permission.write_channel.allow_bits
  public = true
}

moved {
  from = discord_text_channel.general
  to   = discord_text_channel.welcome
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

import {
  id = "1493335630829322312"
  to = discord_text_channel.welcome
}

resource "discord_text_channel" "announcements" {
  name                     = "announcements"
  position                 = index(local.channel_order.top_level, "announcements")
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "futo" {
  name                     = "futo"
  position                 = index(local.channel_order.futo, "futo")
  category                 = discord_category_channel.futo.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "team" {
  name                     = "team"
  position                 = index(local.channel_order.team, "team")
  category                 = discord_category_channel.team.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "server_setup" {
  name                     = "server-setup"
  position                 = index(local.channel_order.team, "server_setup")
  category                 = discord_category_channel.team.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

import {
  id = "1493336762141900880"
  to = discord_text_channel.server_setup
}

resource "discord_text_channel" "futo_keyboard" {
  name                     = "futo-keyboard"
  topic                    = "Privacy respecting Android keyboard"
  position                 = index(local.channel_order.projects, "futo_keyboard")
  category                 = discord_category_channel.projects.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "grayjay" {
  name                     = "grayjay"
  topic                    = "A universal video app for following creators, not platforms"
  position                 = index(local.channel_order.projects, "grayjay")
  category                 = discord_category_channel.projects.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "immich" {
  name                     = "immich"
  topic                    = "High performance self-hosted photo and video management"
  position                 = index(local.channel_order.projects, "immich")
  category                 = discord_category_channel.projects.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "futo_voice" {
  name                     = "futo-voice"
  topic                    = "A voice input app for Android that respects your privacy"
  position                 = index(local.channel_order.projects, "futo_voice")
  category                 = discord_category_channel.projects.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "polycentric" {
  name                     = "polycentric"
  topic                    = "A distributed text-based social network centered around communities"
  position                 = index(local.channel_order.projects, "polycentric")
  category                 = discord_category_channel.projects.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "fcast" {
  name                     = "fcast"
  topic                    = "Open-source protocol designed to open wireless audio and video streaming"
  position                 = index(local.channel_order.projects, "fcast")
  category                 = discord_category_channel.projects.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "live_captions" {
  name                     = "live-captions"
  topic                    = "Accessible live captions that are completely private"
  position                 = index(local.channel_order.projects, "live_captions")
  category                 = discord_category_channel.projects.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "fubs" {
  name                     = "fubs"
  topic                    = "A frictionless and modifiable software development system"
  position                 = index(local.channel_order.projects, "fubs")
  category                 = discord_category_channel.projects.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}

resource "discord_text_channel" "ret" {
  name                     = "ret"
  topic                    = "Reverse-engineering tool"
  position                 = index(local.channel_order.projects, "ret")
  category                 = discord_category_channel.projects.id
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  lifecycle {
    ignore_changes = [sync_perms_with_category]
  }
}
