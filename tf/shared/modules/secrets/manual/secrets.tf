locals {
  secrets = concat(
    var.secrets.global != null ? [
      for name in var.secrets.global : {
        manual_vault = data.onepassword_vault.manual
        vault        = data.onepassword_vault.tf
        name         = name
      }
    ] : [],
    var.secrets.dev != null ? [
      for name in var.secrets.dev : {
        manual_vault = data.onepassword_vault.manual_dev
        vault        = data.onepassword_vault.tf_dev
        name         = name
      }
    ] : [],
    var.secrets.prod != null ? [
      for name in var.secrets.prod : {
        manual_vault = data.onepassword_vault.manual_prod
        vault        = data.onepassword_vault.tf_prod
        name         = name
      }
    ] : []
  )
}

resource "onepassword_item" "manual" {
  for_each = { for idx, secret in local.secrets : "${secret.vault.name}_${secret.name}" => secret }

  vault    = each.value.manual_vault.uuid
  title    = each.value.name
  category = "password"
  password = "REPLACE_ME"

  lifecycle {
    ignore_changes = [password]
  }
}

resource "onepassword_item" "copy" {
  for_each = { for idx, secret in local.secrets : "${secret.vault.name}_${secret.name}" => secret }

  vault    = each.value.vault.uuid
  title    = each.value.name
  category = "password"
  password = onepassword_item.manual[each.key].password
}
