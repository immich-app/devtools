locals {
  users = jsondecode(file(var.users_data_file_path))

  candidate_users = {
    for user in local.users : user.discord.id => user
    if try(user.discord.username, "") != ""
  }
}

data "http" "member_check" {
  for_each = local.candidate_users
  url      = "https://discord.com/api/v10/guilds/${discord_server.server.id}/members/${each.value.discord.id}"
  request_headers = {
    Authorization = "Bot ${var.discord_token}"
  }
  retry {
    attempts     = 5
    min_delay_ms = 1000
    max_delay_ms = 10000
  }
}

resource "discord_member_roles" "roles" {
  for_each = {
    for id, user in local.candidate_users : id => user
    if data.http.member_check[id].status_code == 200
  }

  server_id = discord_server.server.id
  user_id   = each.value.discord.id
  role {
    role_id  = discord_role.admin.id
    has_role = contains(each.value.roles, "immich_admin")
  }

  role {
    role_id  = discord_role.team.id
    has_role = length(setintersection(toset(each.value.roles), toset(["yucca", "team", "immich_admin"]))) > 0
  }

  role {
    role_id  = discord_role.immich.id
    has_role = contains(each.value.roles, "immich")
  }

  role {
    role_id  = discord_role.contributor.id
    has_role = length(setintersection(toset(each.value.roles), toset(["contributor", "futo", "yucca", "team", "immich_admin"]))) > 0
  }

  role {
    role_id  = discord_role.futo.id
    has_role = length(setintersection(toset(each.value.roles), toset(["futo", "yucca", "team", "immich_admin"]))) > 0
  }

  role {
    role_id  = discord_role.support_crew.id
    has_role = contains(each.value.roles, "support")
  }

  role {
    role_id  = discord_role.yucca.id
    has_role = contains(each.value.roles, "yucca")
  }
}
