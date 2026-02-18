locals {
  secrets = concat(
    var.secrets.global != null ? [
      for name in var.secrets.global : {
        manual_vault = data.onepassword_vault.manual_global
        vault        = data.onepassword_vault.copy_global
        name         = name
      }
    ] : [],
    var.secrets.scoped != null ? flatten([
      for manual_vault, copy_vault in var.scoped_vaults : [
        for name in var.secrets.scoped : {
          manual_vault = data.onepassword_vault.manual_scoped[manual_vault]
          vault        = data.onepassword_vault.copy_scoped[manual_vault]
          name         = name
        }
      ]
    ]) : []
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
