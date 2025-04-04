variable "generated_secrets" {
  type = object({
    secrets      = list(string)
    dev_secrets  = list(string)
    prod_secrets = list(string)
  })
  default = {
    secrets = [
      "IMMICH_DISCORD_BOT_GITHUB_STATUS_SLUG",
      "IMMICH_DISCORD_BOT_STRIPE_PAYMENT_SLUG",
      "IMMICH_DISCORD_BOT_GITHUB_WEBHOOK_SLUG",
    ]
    dev_secrets  = ["example"]
    prod_secrets = ["example"]
  }
}

locals {
  generated_secrets = concat(
    [
      for name in var.generated_secrets.secrets : {
        manual_vault = data.onepassword_vault.manual
        vault        = data.onepassword_vault.tf
        name         = name
      }
    ],
    [
      for name in var.generated_secrets.dev_secrets : {
        manual_vault = data.onepassword_vault.manual_dev
        vault        = data.onepassword_vault.tf_dev
        name         = name
      }
    ],
    [
      for name in var.generated_secrets.prod_secrets : {
        manual_vault = data.onepassword_vault.manual_prod
        vault        = data.onepassword_vault.tf_prod
        name         = name
      }
    ]
  )
}

resource "random_password" "generated" {
  for_each = { for idx, secret in local.generated_secrets : "${secret.vault.name}_${secret.name}" => secret }

  length  = 40
  special = false
}

resource "onepassword_item" "generated" {
  for_each = { for idx, secret in local.generated_secrets : "${secret.vault.name}_${secret.name}" => secret }

  vault    = each.value.vault.uuid
  title    = each.value.name
  category = "password"
  password = random_password.generated[each.key].result
}
