data "discord_permission" "everyone" {
  view_channel              = "allow"
  create_instant_invite     = "allow"
  change_nickname           = "allow"
  send_messages             = "allow"
  send_thread_messages      = "allow"
  create_public_threads     = "allow"
  create_private_threads    = "allow"
  embed_links               = "allow"
  attach_files              = "allow"
  add_reactions             = "allow"
  use_external_emojis       = "allow"
  use_external_stickers     = "allow"
  read_message_history      = "allow"
  send_voice_messages       = "allow"
  send_polls                = "allow"
  start_embedded_activities = "allow"
  connect                   = "allow"
  speak                     = "allow"
  stream                    = "allow"
  use_soundboard            = "allow"
  use_external_sounds       = "allow"
  use_vad                   = "allow"
  set_voice_channel_status  = "allow"
  use_application_commands  = "allow"
  use_external_apps         = "allow"
  request_to_speak          = "allow"
}

resource "discord_role_everyone" "everyone" {
  server_id   = discord_server.server.id
  permissions = data.discord_permission.everyone.allow_bits
}

import {
  id = discord_server.server.id
  to = discord_role_everyone.everyone
}

data "discord_color" "package_maintainer" {
  hex = "#E74C3C"
}

resource "discord_role" "package_maintainer" {
  server_id = discord_server.server.id
  name      = "Package Maintainer"
  color     = data.discord_color.package_maintainer.dec
}

import {
  id = "${discord_server.server.id}:1288858805937115229"
  to = discord_role.package_maintainer
}

data "discord_color" "server_booster" {
  hex = "#F47FFF"
}

resource "discord_role" "server_booster" {
  server_id = discord_server.server.id
  name      = "Server Booster"
  color     = data.discord_color.server_booster.dec
}

import {
  id = "${discord_server.server.id}:1045716730456055939"
  to = discord_role.server_booster
}

data "discord_color" "support_crew" {
  hex = "#1F8B4C"
}

data "discord_permission" "support_crew" {
  moderate_members = "allow"
  manage_messages  = "allow"
  move_members     = "allow"
  manage_threads   = "allow"
}

resource "discord_role" "support_crew" {
  server_id   = discord_server.server.id
  name        = "Support Crew"
  permissions = data.discord_permission.support_crew.allow_bits
  color       = data.discord_color.support_crew.dec
  hoist       = true
}

import {
  id = "${discord_server.server.id}:1184258769312551053"
  to = discord_role.support_crew
}

data "discord_color" "mobile_expert" {
  hex = "#2ECC71"
}

resource "discord_role" "mobile_expert" {
  server_id = discord_server.server.id
  name      = "Mobile Expert"
  color     = data.discord_color.mobile_expert.dec
}

import {
  id = "${discord_server.server.id}:1070359265371500554"
  to = discord_role.mobile_expert
}

data "discord_color" "security_researcher" {
  hex = "#206694"
}

resource "discord_role" "security_researcher" {
  server_id = discord_server.server.id
  name      = "Security Researcher"
  color     = data.discord_color.security_researcher.dec
}

import {
  id = "${discord_server.server.id}:1020479701040508938"
  to = discord_role.security_researcher
}

data "discord_color" "in_the_zone" {
  hex = "#FF0000"
}

resource "discord_role" "in_the_zone" {
  server_id = discord_server.server.id
  name      = "In The Zone"
  color     = data.discord_color.in_the_zone.dec
  hoist     = true
}

import {
  id = "${discord_server.server.id}:1194042573258498098"
  to = discord_role.in_the_zone
}

data "discord_permission" "contributor" {
  allow_extends    = data.discord_permission.support_crew.allow_bits
  mention_everyone = "allow"
}

data "discord_color" "contributor" {
  hex = "#29A0BE"
}

resource "discord_role" "contributor" {
  server_id   = discord_server.server.id
  name        = "Contributor"
  permissions = data.discord_permission.contributor.allow_bits
  color       = data.discord_color.contributor.dec
  hoist       = true
}

import {
  id = "${discord_server.server.id}:980972470964215870"
  to = discord_role.contributor
}

data "discord_color" "team" {
  hex = "#ADCAFA"
}

resource "discord_role" "team" {
  server_id = discord_server.server.id
  name      = "Team"
  color     = data.discord_color.team.dec
  hoist     = true
}

import {
  id = "${discord_server.server.id}:1330248951613358101"
  to = discord_role.team
}

data "discord_color" "head_down" {
  hex = "#FF0000"
}

resource "discord_role" "head_down" {
  server_id = discord_server.server.id
  name      = "Head Down"
  color     = data.discord_color.head_down.dec
}

import {
  id = "${discord_server.server.id}:1235198938349441054"
  to = discord_role.head_down
}

data "discord_permission" "administrator" {
  administrator = "allow"
}

data "discord_color" "hidden_admin" {
  hex = "#95A5A6"
}

resource "discord_role" "hidden_admin" {
  server_id   = discord_server.server.id
  name        = "Hidden Admin"
  permissions = data.discord_permission.administrator.allow_bits
  color       = data.discord_color.hidden_admin.dec
}

import {
  id = "${discord_server.server.id}:1194350448459653241"
  to = discord_role.hidden_admin
}

data "discord_permission" "fake_admin" {
  view_channel              = "allow"
  manage_channels           = "allow"
  manage_roles              = "allow"
  create_expressions        = "allow"
  manage_emojis             = "allow"
  view_audit_log            = "allow"
  view_guild_insights       = "allow"
  manage_webhooks           = "allow"
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
  connect                   = "allow"
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
}

data "discord_color" "admin" {
  hex = "#F1C40F"
}

resource "discord_role" "admin" {
  server_id   = discord_server.server.id
  name        = "Admin"
  permissions = data.discord_permission.fake_admin.allow_bits
  color       = data.discord_color.admin.dec
  hoist       = true
}

import {
  id = "${discord_server.server.id}:991443154182078484"
  to = discord_role.admin
}
