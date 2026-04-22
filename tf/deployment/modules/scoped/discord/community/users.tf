locals {
  users = jsondecode(file(var.users_data_file_path))

  candidate_users = {
    for user in local.users : user.discord.id => user
    if try(user.discord.username, "") != ""
  }
}

data "external" "members" {
  program = ["${path.module}/scripts/check-members.sh"]
  query = {
    token     = var.discord_token
    server_id = discord_server.server.id
    user_ids  = join(",", [for user in local.candidate_users : user.discord.id])
  }
}

resource "discord_member_roles" "roles" {
  for_each = {
    for id, user in local.candidate_users : id => user
    if contains(jsondecode(data.external.members.result.member_ids), id)
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
