data "onepassword_vault" "opentofu" {
  name = "OpenTofu"
}

data "onepassword_vault" "kubernetes" {
  name = "Kubernetes"
}

resource "onepassword_item" "mich_cloudflare_r2_tf_state_database_backups_bucket" {
  vault    = data.onepassword_vault.kubernetes.uuid
  title    = "mich-cloudflare-r2-tf-state-database-backup-bucket"
  category = "secure_note"
  section {
    label = "Cloudflare R2 Token"

    field {
      label = "bucket-name"
      type  = "STRING"
      value = cloudflare_r2_bucket.tf_state_database_backups.name
    }

    field {
      label = "api-endpoint"
      type  = "STRING"
      value = "https://${cloudflare_r2_bucket.tf_state_database_backups.account_id}.r2.cloudflarestorage.com"
    }
  }
}
