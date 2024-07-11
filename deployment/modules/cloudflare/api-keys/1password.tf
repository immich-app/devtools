data "onepassword_vault" "opentofu" {
  name = "OpenTofu"
}

data "onepassword_vault" "kubernetes" {
  name = "Kubernetes"
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
