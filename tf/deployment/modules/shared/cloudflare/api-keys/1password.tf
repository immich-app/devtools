data "onepassword_vault" "opentofu" {
  name = "OpenTofu"
}

data "onepassword_vault" "kubernetes" {
  name = "Kubernetes"
}

data "onepassword_vault" "tf" {
  name = "tf"
}

resource "onepassword_item" "mich_cloudflare_r2_token" {
  vault    = data.onepassword_vault.kubernetes.uuid
  title    = "mich-cloudflare-r2-token"
  category = "secure_note"
  section {
    label = "Cloudflare R2 Token"

    field {
      label = "id"
      type  = "STRING"
      value = cloudflare_api_token.mich_cloudflare_r2_token.id
    }

    field {
      label = "secret"
      type  = "STRING"
      value = sha256(cloudflare_api_token.mich_cloudflare_r2_token.value)
    }
  }
}

resource "onepassword_item" "static_bucket_key_id" {
  vault    = data.onepassword_vault.tf.uuid
  title    = "STATIC_BUCKET_KEY_ID"
  category = "password"
  password = cloudflare_api_token.static_bucket_api_token.id
}

resource "onepassword_item" "static_bucket_key_secret" {
  vault    = data.onepassword_vault.tf.uuid
  title    = "STATIC_BUCKET_KEY_SECRET"
  category = "password"
  password = sha256(cloudflare_api_token.static_bucket_api_token.value)
}
