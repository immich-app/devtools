locals {
  users = jsondecode(file(var.users_data_file_path))
}

resource "discord_member_roles" "roles" {
  for_each = { for user in local.users : user.discord.id => user if(var.env == "prod" || lookup(user, "dev", false)) && try(user.discord.username, "") != "" }

  server_id = discord_server.server.id
  user_id   = each.value.discord.id
  role {
    role_id  = discord_role.admin.id
    has_role = contains(each.value.roles, "admin")
  }

  role {
    role_id  = discord_role.team.id
    has_role = length(setintersection(toset(each.value.roles), toset(["yucca", "team", "admin"]))) > 0
  }

  role {
    role_id  = discord_role.contributor.id
    has_role = length(setintersection(toset(each.value.roles), toset(["contributor", "futo", "yucca", "team", "admin"]))) > 0
  }

  role {
    role_id  = discord_role.futo.id
    has_role = length(setintersection(toset(each.value.roles), toset(["futo", "yucca", "team", "admin"]))) > 0
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
