locals {
  secrets = concat(
    var.secrets.global != null ? [
      for secret_obj in var.secrets.global : {
        vault  = data.onepassword_vault.tf
        name   = secret_obj.name
        length = secret_obj.length
      }
    ] : [],
    var.secrets.dev != null ? [
      for secret_obj in var.secrets.dev : {
        vault  = data.onepassword_vault.tf_dev
        name   = secret_obj.name
        length = secret_obj.length
      }
    ] : [],
    var.secrets.prod != null ? [
      for secret_obj in var.secrets.prod : {
        vault  = data.onepassword_vault.tf_prod
        name   = secret_obj.name
        length = secret_obj.length
      }
    ] : []
  )
}

resource "random_password" "generated" {
  for_each = { for idx, secret in local.secrets : "${secret.vault.name}_${secret.name}" => secret }

  length  = each.value.length != null ? each.value.length : var.default_secret_length
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
