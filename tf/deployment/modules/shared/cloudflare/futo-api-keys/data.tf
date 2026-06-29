data "onepassword_vault" "shared_tf" {
  name = "shared_tf"
}

data "onepassword_item" "cloudflare_api_token" {
  vault = data.onepassword_vault.shared_tf.uuid
  title = "CLOUDFLARE_API_TOKEN"
}

data "onepassword_item" "cloudflare_account_id" {
  vault = data.onepassword_vault.shared_tf.uuid
  title = "CLOUDFLARE_ACCOUNT_ID"
}

locals {
  account_id = data.onepassword_item.cloudflare_account_id.password
}
