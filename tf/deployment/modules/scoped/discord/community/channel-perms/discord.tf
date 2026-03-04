locals {
  role_channel_combinations = flatten([
    for role_key, role_id in var.roles : [
      for channel_key, channel_id in var.channels : {
        key        = "${role_key}/${channel_key}"
        role_id    = role_id
        channel_id = channel_id
      }
    ]
  ])
}

resource "discord_channel_permission" "permissions" {
  for_each = { for combo in local.role_channel_combinations : combo.key => combo }

  channel_id   = each.value.channel_id
  type         = "role"
  overwrite_id = each.value.role_id
  allow        = var.allow
  deny         = var.deny
}

data "discord_permission" "deny_channel" {
  view_channel = "deny"
  connect      = "deny"
}

resource "discord_channel_permission" "private" {
  for_each = var.public ? {} : var.channels

  channel_id   = each.value
  type         = "role"
  overwrite_id = var.everyone_id

  deny = data.discord_permission.deny_channel.deny_bits
}
