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

resource "random_password" "outline_backups_restic_secret" {
  length           = 40
  special          = true
  override_special = "!@#$%^&*()_+"
}

resource "onepassword_item" "mich_cloudflare_r2_outline_volsync_backup" {
  vault    = data.onepassword_vault.kubernetes.uuid
  title    = "mich-cloudflare-r2-outline-volsync-backup"
  category = "secure_note"
  section {
    label = "Cloudflare R2 Bucket"

    field {
      label = "RESTIC_REPOSITORY"
      type  = "STRING"
      value = "s3:https://${cloudflare_r2_bucket.outline_volsync_backups.account_id}.r2.cloudflarestorage.com/${cloudflare_r2_bucket.outline_volsync_backups.name}"
    }

    field {
      label = "RESTIC_PASSWORD"
      type  = "CONCEALED"
      value = random_password.outline_backups_restic_secret.result
    }

    field {
      label = "AWS_ACCESS_KEY_ID"
      type  = "CONCEALED"
      value = data.terraform_remote_state.api_keys_state.outputs.mich_cloudflare_r2_token_id
    }

    field {
      label = "AWS_SECRET_ACCESS_KEY"
      type  = "CONCEALED"
      value = sha256(data.terraform_remote_state.api_keys_state.outputs.mich_cloudflare_r2_token_value)
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
