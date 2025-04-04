variable "manual_secrets" {
  type = object({
    secrets      = list(string)
    dev_secrets  = list(string)
    prod_secrets = list(string)
  })
  default = {
    secrets = [
      "IMMICH_DISCORD_BOT_TOKEN",
      "IMMICH_ZULIP_BOT_USERNAME",
      "IMMICH_ZULIP_BOT_API_KEY",
      "IMMICH_GITHUB_CLIENT_ID",
      "IMMICH_GITHUB_CLIENT_SECRET",
      "FUTO_ZULIP_DOMAIN",
      "FOURTHWALL_USER",
      "FOURTHWALL_PASSWORD"
    ]
    dev_secrets  = ["example"]
    prod_secrets = ["example"]
  }
}

locals {
  manual_secrets = concat(
    [
      for name in var.manual_secrets.secrets : {
        manual_vault = data.onepassword_vault.manual
        vault        = data.onepassword_vault.tf
        name         = name
      }
    ],
    [
      for name in var.manual_secrets.dev_secrets : {
        manual_vault = data.onepassword_vault.manual_dev
        vault        = data.onepassword_vault.tf_dev
        name         = name
      }
    ],
    [
      for name in var.manual_secrets.prod_secrets : {
        manual_vault = data.onepassword_vault.manual_prod
        vault        = data.onepassword_vault.tf_prod
        name         = name
      }
    ]
  )
}

resource "onepassword_item" "manual" {
  for_each = { for idx, secret in local.manual_secrets : "${secret.vault.name}_${secret.name}" => secret }

  vault    = each.value.manual_vault.uuid
  title    = each.value.name
  category = "password"
  password = "REPLACE_ME"

  lifecycle {
    ignore_changes = [password]
  }
}

resource "onepassword_item" "copy" {
  for_each = { for idx, secret in local.manual_secrets : "${secret.vault.name}_${secret.name}" => secret }

  vault    = each.value.vault.uuid
  title    = each.value.name
  category = "password"
  password = onepassword_item.manual[each.key].password
}

output "manual_secret_values" {
  value = {
    for secret in local.manual_secrets :
    secret.name => onepassword_item.copy[format("${secret.vault.name}_${secret.name}")].password
  }
}
