locals {
  role_order = [
    "admin",
    "futo",
    "futo_keyboard",
    "grayjay",
    "immich",
    "futo_voice",
    "polycentric",
    "fcast",
    "live_captions",
    "fubs",
    "ret",
    "server_booster",
  ]
}

data "discord_permission" "everyone" {
  create_instant_invite = "allow"
  change_nickname       = "allow"
}

resource "discord_role_everyone" "everyone" {
  server_id   = discord_server.server.id
  permissions = data.discord_permission.everyone.allow_bits
}

data "discord_permission" "administrator" {
  administrator = "allow"
}

data "discord_color" "admin" {
  hex = "#FFB400"
}

resource "discord_role" "admin" {
  server_id   = discord_server.server.id
  name        = "Admin"
  permissions = data.discord_permission.administrator.allow_bits
  color       = data.discord_color.admin.dec
  hoist       = true
}

import {
  id = "${var.futo_discord_server_id}:1493336031897063595"
  to = discord_role.admin
}

data "discord_permission" "futo" {
  create_expressions        = "allow"
  manage_emojis             = "allow"
  view_guild_insights       = "allow"
  manage_guild              = "allow"
  create_instant_invite     = "allow"
  change_nickname           = "allow"
  manage_nicknames          = "allow"
  kick_members              = "allow"
  ban_members               = "allow"
  moderate_members          = "allow"
  send_messages             = "allow"
  send_thread_messages      = "allow"
  create_public_threads     = "allow"
  create_private_threads    = "allow"
  embed_links               = "allow"
  attach_files              = "allow"
  add_reactions             = "allow"
  use_external_emojis       = "allow"
  use_external_stickers     = "allow"
  mention_everyone          = "allow"
  manage_messages           = "allow"
  manage_threads            = "allow"
  read_message_history      = "allow"
  send_tts_messages         = "allow"
  send_voice_messages       = "allow"
  send_polls                = "allow"
  speak                     = "allow"
  stream                    = "allow"
  use_soundboard            = "allow"
  use_external_sounds       = "allow"
  use_vad                   = "allow"
  priority_speaker          = "allow"
  mute_members              = "allow"
  deafen_members            = "allow"
  move_members              = "allow"
  set_voice_channel_status  = "allow"
  use_application_commands  = "allow"
  start_embedded_activities = "allow"
  request_to_speak          = "allow"
  create_events             = "allow"
  manage_events             = "allow"
  view_audit_log            = "allow"
  pin_messages              = "allow"
  bypass_slowmode           = "allow"
}

data "discord_color" "futo" {
  hex = "#254466"
}

resource "discord_role" "futo" {
  server_id   = discord_server.server.id
  name        = "FUTO"
  permissions = data.discord_permission.futo.allow_bits
  color       = data.discord_color.futo.dec
  hoist       = true
}

data "discord_color" "futo_keyboard" {
  hex = "#4A90D9"
}

resource "discord_role" "futo_keyboard" {
  server_id = discord_server.server.id
  name      = "FUTO Keyboard"
  color     = data.discord_color.futo_keyboard.dec
}

data "discord_color" "grayjay" {
  hex = "#1E8BC3"
}

resource "discord_role" "grayjay" {
  server_id = discord_server.server.id
  name      = "Grayjay"
  color     = data.discord_color.grayjay.dec
}

data "discord_color" "immich" {
  hex = "#4250AF"
}

resource "discord_role" "immich" {
  server_id = discord_server.server.id
  name      = "Immich"
  color     = data.discord_color.immich.dec
}

data "discord_color" "futo_voice" {
  hex = "#9B59B6"
}

resource "discord_role" "futo_voice" {
  server_id = discord_server.server.id
  name      = "FUTO Voice"
  color     = data.discord_color.futo_voice.dec
}

data "discord_color" "polycentric" {
  hex = "#2ECC71"
}

resource "discord_role" "polycentric" {
  server_id = discord_server.server.id
  name      = "Polycentric"
  color     = data.discord_color.polycentric.dec
}

data "discord_color" "fcast" {
  hex = "#1ABC9C"
}

resource "discord_role" "fcast" {
  server_id = discord_server.server.id
  name      = "FCast"
  color     = data.discord_color.fcast.dec
}

data "discord_color" "live_captions" {
  hex = "#E74C3C"
}

resource "discord_role" "live_captions" {
  server_id = discord_server.server.id
  name      = "Live Captions"
  color     = data.discord_color.live_captions.dec
}

data "discord_color" "fubs" {
  hex = "#F1C40F"
}

resource "discord_role" "fubs" {
  server_id = discord_server.server.id
  name      = "FUBS"
  color     = data.discord_color.fubs.dec
}

data "discord_color" "ret" {
  hex = "#95A5A6"
}

resource "discord_role" "ret" {
  server_id = discord_server.server.id
  name      = "Ret"
  color     = data.discord_color.ret.dec
}

data "discord_color" "server_booster" {
  hex = "#E55353"
}

resource "discord_role" "server_booster" {
  server_id = discord_server.server.id
  name      = "Server Booster"
  color     = data.discord_color.server_booster.dec
}

import {
  id = "${var.futo_discord_server_id}:1493337762902970460"
  to = discord_role.server_booster
}
