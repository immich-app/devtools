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
      label = "bucket_name"
      type  = "STRING"
      value = cloudflare_r2_bucket.tf_state_database_backups.name
    }

    field {
      label = "api_endpoint"
      type  = "STRING"
      value = "https://${cloudflare_r2_bucket.tf_state_database_backups.account_id}.r2.cloudflarestorage.com"
    }
  }
}

resource "random_password" "victoriametrics_backups_restic_secret" {
  length           = 40
  special          = true
  override_special = "!@#$%^&*()_+"
}


resource "onepassword_item" "mich_cloudflare_r2_victoriametrics_backups_bucket" {
  vault    = data.onepassword_vault.kubernetes.uuid
  title    = "mich-cloudflare-r2-victoriametrics-backup-bucket"
  category = "secure_note"
  section {
    label = "Cloudflare R2 Token"

    field {
      label = "bucket_name"
      type  = "STRING"
      value = cloudflare_r2_bucket.victoriametrics_backups.name
    }

    field {
      label = "api_endpoint"
      type  = "STRING"
      value = "https://${cloudflare_r2_bucket.victoriametrics_backups.account_id}.r2.cloudflarestorage.com"
    }

    field {
      label = "restic_secret"
      type  = "CONCEALED"
      value = random_password.victoriametrics_backups_restic_secret.result
    }
  }
}

resource "random_password" "data_pipeline_vmetrics_backups_restic_secret" {
  length           = 40
  special          = true
  override_special = "!@#$%^&*()_+"
}


resource "onepassword_item" "mich_cloudflare_r2_data_pipeline_vmetrics_backups_bucket" {
  vault    = data.onepassword_vault.kubernetes.uuid
  title    = "mich-cloudflare-r2-data-pipeline-vmetrics-backup-bucket"
  category = "secure_note"
  section {
    label = "Cloudflare R2 Token"

    field {
      label = "bucket_name"
      type  = "STRING"
      value = cloudflare_r2_bucket.data_pipeline_vmetrics_backups.name
    }

    field {
      label = "api_endpoint"
      type  = "STRING"
      value = "https://${cloudflare_r2_bucket.data_pipeline_vmetrics_backups.account_id}.r2.cloudflarestorage.com"
    }

    field {
      label = "restic_secret"
      type  = "CONCEALED"
      value = random_password.data_pipeline_vmetrics_backups_restic_secret.result
    }
  }
}

resource "onepassword_item" "mich_cloudflare_r2_outline_database_backups_bucket" {
  vault    = data.onepassword_vault.kubernetes.uuid
  title    = "mich-cloudflare-r2-outline-database-backup-bucket"
  category = "secure_note"
  section {
    label = "Cloudflare R2 Bucket"

    field {
      label = "bucket_name"
      type  = "STRING"
      value = cloudflare_r2_bucket.outline_database_backups.name
    }

    field {
      label = "api_endpoint"
      type  = "STRING"
      value = "https://${cloudflare_r2_bucket.outline_database_backups.account_id}.r2.cloudflarestorage.com"
    }
  }
}

resource "onepassword_item" "static_bucket_name" {
  vault    = data.onepassword_vault.tf.uuid
  title    = "STATIC_BUCKET_NAME"
  category = "password"
  password = cloudflare_r2_bucket.static.name
}

resource "onepassword_item" "static_bucket_endpoint" {
  vault    = data.onepassword_vault.tf.uuid
  title    = "STATIC_BUCKET_ENDPOINT"
  category = "password"
  password = "https://${var.cloudflare_account_id}.r2.cloudflarestorage.com"
}

resource "onepassword_item" "static_bucket_region" {
  vault    = data.onepassword_vault.tf.uuid
  title    = "STATIC_BUCKET_REGION"
  category = "password"
  password = "auto"
}
