locals {
  role_order = [
    "admin",
    "hidden_admin",
    "head_down",
    "team",
    "contributor",
    "in_the_zone",
    "security_researcher",
    "mobile_expert",
    "support_crew",
    "package_maintainer",
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

data "discord_color" "package_maintainer" {
  hex = "#E74C3C"
}

resource "discord_role" "package_maintainer" {
  server_id = discord_server.server.id
  name      = "Package Maintainer"
  color     = data.discord_color.package_maintainer.dec
}

data "discord_color" "server_booster" {
  hex = "#E55353"
}

resource "discord_role" "server_booster" {
  server_id = discord_server.server.id
  name      = "Server Booster"
  color     = data.discord_color.server_booster.dec
}

data "discord_color" "support_crew" {
  hex = "#18C249"
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

data "discord_color" "mobile_expert" {
  hex = "#2ECC71"
}

resource "discord_role" "mobile_expert" {
  server_id = discord_server.server.id
  name      = "Mobile Expert"
  color     = data.discord_color.mobile_expert.dec
}

data "discord_color" "security_researcher" {
  hex = "#206694"
}

resource "discord_role" "security_researcher" {
  server_id = discord_server.server.id
  name      = "Security Researcher"
  color     = data.discord_color.security_researcher.dec
}

data "discord_color" "in_the_zone" {
  hex = "#FA2921"
}

resource "discord_role" "in_the_zone" {
  server_id = discord_server.server.id
  name      = "In The Zone"
  color     = data.discord_color.in_the_zone.dec
  hoist     = true
}

data "discord_permission" "contributor" {
  allow_extends    = data.discord_permission.support_crew.allow_bits
  mention_everyone = "allow"
}

data "discord_color" "contributor" {
  hex = "#ED79B5"
}

resource "discord_role" "contributor" {
  server_id   = discord_server.server.id
  name        = "Contributor"
  permissions = data.discord_permission.contributor.allow_bits
  color       = data.discord_color.contributor.dec
  hoist       = true
}

data "discord_color" "team" {
  hex = "#1E83F7"
}

resource "discord_role" "team" {
  server_id = discord_server.server.id
  name      = "Team"
  color     = data.discord_color.team.dec
  hoist     = true
}

data "discord_color" "head_down" {
  hex = "#FA2921"
}

resource "discord_role" "head_down" {
  server_id = discord_server.server.id
  name      = "Head Down"
  color     = data.discord_color.head_down.dec
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
  hex = "#FFB400"
}

resource "discord_role" "admin" {
  server_id   = discord_server.server.id
  name        = "Admin"
  permissions = data.discord_permission.fake_admin.allow_bits
  color       = data.discord_color.admin.dec
  hoist       = true
}
