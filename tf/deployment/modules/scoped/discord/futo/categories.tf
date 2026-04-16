locals {
  category_order = [
    "futo",
    "projects",
    "team",
  ]
}

data "discord_permission" "category" {
  view_channel    = "deny"
  manage_channels = "deny"
}

module "category_perms" {
  source = "./channel-perms"
  channels = {
    futo     = discord_category_channel.futo.id
    projects = discord_category_channel.projects.id
    team     = discord_category_channel.team.id
  }
  roles = {
    everyone = discord_role_everyone.everyone.id
  }
  allow  = data.discord_permission.category.allow_bits
  deny   = data.discord_permission.category.deny_bits
  public = true
}

resource "discord_category_channel" "futo" {
  name      = "FUTO"
  server_id = discord_server.server.id
  position  = index(local.category_order, "futo")
}

resource "discord_category_channel" "projects" {
  name      = "Projects"
  server_id = discord_server.server.id
  position  = index(local.category_order, "projects")
}

resource "discord_category_channel" "team" {
  name      = "Team"
  server_id = discord_server.server.id
  position  = index(local.category_order, "team")
}
