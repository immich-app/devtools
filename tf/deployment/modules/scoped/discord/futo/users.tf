locals {
  users = jsondecode(file(var.users_data_file_path))

  assignable_role_tags = toset([
    "futo",
    "futo_admin",
    "immich",
    "futo_keyboard",
    "grayjay",
    "futo_voice",
    "polycentric",
    "fcast",
    "live_captions",
    "fubs",
    "ret",
  ])

  candidate_users = {
    for user in local.users : user.discord.id => user
    if try(user.discord.username, "") != ""
    && length(setintersection(toset(user.roles), local.assignable_role_tags)) > 0
  }
}

data "http" "member_check" {
  for_each = local.candidate_users
  url      = "https://discord.com/api/v10/guilds/${discord_server.server.id}/members/${each.value.discord.id}"
  request_headers = {
    Authorization = "Bot ${var.futo_discord_token}"
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
    has_role = contains(each.value.roles, "futo_admin")
  }

  role {
    role_id  = discord_role.futo.id
    has_role = length(setintersection(toset(each.value.roles), toset(["futo", "futo_admin"]))) > 0
  }

  role {
    role_id  = discord_role.immich.id
    has_role = contains(each.value.roles, "immich")
  }

  role {
    role_id  = discord_role.futo_keyboard.id
    has_role = contains(each.value.roles, "futo_keyboard")
  }

  role {
    role_id  = discord_role.grayjay.id
    has_role = contains(each.value.roles, "grayjay")
  }

  role {
    role_id  = discord_role.futo_voice.id
    has_role = contains(each.value.roles, "futo_voice")
  }

  role {
    role_id  = discord_role.polycentric.id
    has_role = contains(each.value.roles, "polycentric")
  }

  role {
    role_id  = discord_role.fcast.id
    has_role = contains(each.value.roles, "fcast")
  }

  role {
    role_id  = discord_role.live_captions.id
    has_role = contains(each.value.roles, "live_captions")
  }

  role {
    role_id  = discord_role.fubs.id
    has_role = contains(each.value.roles, "fubs")
  }

  role {
    role_id  = discord_role.ret.id
    has_role = contains(each.value.roles, "ret")
  }
}
