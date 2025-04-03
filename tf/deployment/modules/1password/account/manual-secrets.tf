data "onepassword_vault" "manual" {
  name = "tf_manual"
}

data "onepassword_vault" "manual_dev" {
  name = "tf_dev_manual"
}

data "onepassword_vault" "manual_prod" {
  name = "tf_prod_manual"
}

variable "repositories" {
  type = object({
    secrets      = list(string)
    dev_secrets  = list(string)
    prod_secrets = list(string)
  })
  default = {
    secrets      = ["example"]
    dev_secrets  = ["example"]
    prod_secrets = ["example"]
  }
}

locals {
  all_secrets = concat(
    [
      for name in var.repositories.secrets : {
        vault = data.onepassword_vault.manual
        name  = name
      }
    ],
    [
      for name in var.repositories.dev_secrets : {
        vault = data.onepassword_vault.manual_dev
        name  = name
      }
    ],
    [
      for name in var.repositories.prod_secrets : {
        vault = data.onepassword_vault.manual_prod
        name  = name
      }
    ]
  )
}

resource "onepassword_item" "manual" {
  for_each = { for idx, secret in local.all_secrets : "${secret.vault.name}_${secret.name}" => secret }

  vault    = each.value.vault.uuid
  title    = each.value.name
  category = "password"
  password = "REPLACE_ME"

  lifecycle {
    ignore_changes = [password]
  }
}
