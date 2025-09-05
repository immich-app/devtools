locals {
  category_order = [
    "immich",
    "community",
    "support_crew",
    "development",
    "team",
    "yucca",
    "leadership",
    "third_parties",
    "off_topic",
    "voice",
    "archive"
  ]
}

data "discord_permission" "category" {
  view_channel    = "deny"
  manage_channels = "deny"
}

module "category_perms" {
  source = "./channel-perms"
  channel_ids = [
    discord_category_channel.immich.id,
    discord_category_channel.community.id,
    discord_category_channel.development.id,
    discord_category_channel.team.id,
    discord_category_channel.yucca.id,
    discord_category_channel.leadership.id,
    discord_category_channel.third_parties.id,
    discord_category_channel.off_topic.id,
    discord_category_channel.voice.id,
    discord_category_channel.archive.id
  ]
  role_ids = [discord_role_everyone.everyone.id]
  allow    = data.discord_permission.category.allow_bits
  deny     = data.discord_permission.category.deny_bits
  public   = true
}

resource "discord_category_channel" "immich" {
  name      = "Immich"
  server_id = discord_server.server.id
  position  = index(local.category_order, "immich")
}

resource "discord_category_channel" "community" {
  name      = "Community"
  server_id = discord_server.server.id
  position  = index(local.category_order, "community")
}

resource "discord_category_channel" "support_crew" {
  name      = "Support Crew"
  server_id = discord_server.server.id
  position  = index(local.category_order, "support_crew")
}

resource "discord_category_channel" "development" {
  name      = "Development"
  server_id = discord_server.server.id
  position  = index(local.category_order, "development")
}

resource "discord_category_channel" "team" {
  name      = "Team"
  server_id = discord_server.server.id
  position  = index(local.category_order, "team")
}

resource "discord_category_channel" "yucca" {
  name      = "Yucca"
  server_id = discord_server.server.id
  position  = index(local.category_order, "yucca")
}

resource "discord_category_channel" "leadership" {
  name      = "Leadership"
  server_id = discord_server.server.id
  position  = index(local.category_order, "leadership")
}

resource "discord_category_channel" "third_parties" {
  name      = "Third Parties"
  server_id = discord_server.server.id
  position  = index(local.category_order, "third_parties")
}

resource "discord_category_channel" "off_topic" {
  name      = "Off Topic"
  server_id = discord_server.server.id
  position  = index(local.category_order, "off_topic")
}

resource "discord_category_channel" "voice" {
  name      = "Voice"
  server_id = discord_server.server.id
  position  = index(local.category_order, "voice")
}

resource "discord_category_channel" "archive" {
  name      = "Archive"
  server_id = discord_server.server.id
  position  = index(local.category_order, "archive")
}
