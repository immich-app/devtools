locals {
  users = jsondecode(file(var.users_data_file_path))
}

resource "discord_member_roles" "roles" {
  for_each = { for user in local.users : user.discord.id => user if(var.env == "prod" || lookup(user, "dev", false)) && try(user.discord.username, "") != "" }

  server_id = discord_server.server.id
  user_id   = each.value.discord.id
  role {
    role_id  = discord_role.admin.id
    has_role = contains(["admin"], each.value.role)
  }

  role {
    role_id  = discord_role.team.id
    has_role = contains(["team", "admin"], each.value.role)
  }

  role {
    role_id  = discord_role.contributor.id
    has_role = contains(["contributor", "futo", "yucca", "team", "admin"], each.value.role)
  }

  role {
    role_id  = discord_role.futo.id
    has_role = contains(["futo", "yucca", "team", "admin"], each.value.role)
  }

  role {
    role_id  = discord_role.support_crew.id
    has_role = contains(["support"], each.value.role)
  }
}
