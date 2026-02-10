locals {
  secrets = concat(
    var.secrets.global != null ? [
      for secret_obj in var.secrets.global : {
        vault  = data.onepassword_vault.global
        name   = secret_obj.name
        length = secret_obj.length
        type   = secret_obj.type
      }
    ] : [],
    var.secrets.scoped != null ? flatten([
      for vault_name in var.scoped_vaults : [
        for secret_obj in var.secrets.scoped : {
          vault  = data.onepassword_vault.scoped[vault_name]
          name   = secret_obj.name
          length = secret_obj.length
          type   = secret_obj.type
        }
      ]
    ]) : []
  )
}

resource "random_password" "generated" {
  for_each = { for idx, secret in local.secrets : "${secret.vault.name}_${secret.name}" => secret }

  length  = each.value.length != null ? each.value.length : var.default_secret_length
  lower   = each.value.type != null && each.value.type != "numeric" ? true : false
  upper   = each.value.type != null && each.value.type != "numeric" ? true : false
  numeric = each.value.type != null && each.value.type != "alphabetic" ? true : false
  special = false
}

resource "onepassword_item" "generated" {
  for_each = { for idx, secret in local.secrets : "${secret.vault.name}_${secret.name}" => secret }

  vault    = each.value.vault.uuid
  title    = each.value.name
  category = "password"
  password = random_password.generated[each.key].result
}
