data "onepassword_vault" "shared_tf" {
  name = "shared_tf"
}

data "onepassword_item" "cloudflare_account_id" {
  vault = data.onepassword_vault.shared_tf.uuid
  title = "CLOUDFLARE_ACCOUNT_ID"
}

locals {
  cloudflare_account_id = data.onepassword_item.cloudflare_account_id.password
}
