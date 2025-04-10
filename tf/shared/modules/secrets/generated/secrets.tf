locals {
  secrets = concat(
    var.secrets.global != null ? [
      for name in var.secrets.global : {
        vault = data.onepassword_vault.tf
        name  = name
      }
    ] : [],
    var.secrets.dev != null ? [
      for name in var.secrets.dev : {
        vault = data.onepassword_vault.tf_dev
        name  = name
      }
    ] : [],
    var.secrets.prod != null ? [
      for name in var.secrets.prod : {
        vault = data.onepassword_vault.tf_prod
        name  = name
      }
    ] : []
  )
}

resource "random_password" "generated" {
  for_each = { for idx, secret in local.secrets : "${secret.vault.name}_${secret.name}" => secret }

  length  = 40
  special = false
}

resource "onepassword_item" "generated" {
  for_each = { for idx, secret in local.secrets : "${secret.vault.name}_${secret.name}" => secret }

  vault    = each.value.vault.uuid
  title    = each.value.name
  category = "password"
  password = random_password.generated[each.key].result
}

output "global_values" {
  value = {
    for secret in local.secrets :
    secret.name => onepassword_item.generated[format("${secret.vault.name}_${secret.name}")].password
  }
}
