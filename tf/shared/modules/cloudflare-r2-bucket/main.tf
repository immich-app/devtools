resource "cloudflare_r2_bucket" "bucket" {
  account_id = var.cloudflare_account_id
  name       = var.bucket_name
  location   = var.location
}

// Create the API token for R2 bucket access
resource "cloudflare_api_token" "bucket_api_token" {
  name     = "r2_token_${var.bucket_name}"
  provider = cloudflare.api_keys

  // First policy for R2 storage access
  policy {
    permission_groups = [
      "com.cloudflare.api.account.worker.r2.storage.read",
      "com.cloudflare.api.account.worker.r2.storage.write"
    ]
    resources = {
      "com.cloudflare.api.account.*" = "*"
    }
  }

  // Second policy specifically for R2 bucket item operations
  policy {
    permission_groups = [
      "com.cloudflare.edge.r2.bucket.object_read",
      "com.cloudflare.edge.r2.bucket.object_write"
    ]
    resources = {
      "com.cloudflare.edge.r2.bucket.${var.bucket_name}" = "*"
    }
  }

  // Add IP restrictions if specified
  dynamic "condition" {
    for_each = length(var.allowed_ips) > 0 ? [1] : []
    content {
      request_ip {
        in = var.allowed_ips
      }
    }
  }
}

// Store credentials in 1Password
resource "onepassword_item" "bucket_credentials" {
  vault    = var.onepassword_vault_id
  title    = var.item_name
  category = "secure_note"

  section {
    label = "Cloudflare R2 Bucket"

    field {
      label = "bucket_name"
      type  = "STRING"
      value = cloudflare_r2_bucket.bucket.name
    }

    field {
      label = "endpoint"
      type  = "STRING"
      value = "https://${var.cloudflare_account_id}.r2.cloudflarestorage.com"
    }

    field {
      label = "access_key_id"
      type  = "CONCEALED"
      value = cloudflare_api_token.bucket_api_token.id
    }

    field {
      label = "secret_access_key"
      type  = "CONCEALED"
      value = cloudflare_api_token.bucket_api_token.value
    }
  }
}
