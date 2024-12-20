data "onepassword_vault" "opentofu" {
  name = "OpenTofu"
}

data "onepassword_vault" "kubernetes" {
  name = "Kubernetes"
}

data "onepassword_vault" "tf_dev" {
  name = "tf_dev"
}

data "onepassword_vault" "tf_prod" {
  name = "tf_prod"
}

resource "tls_private_key" "containerssh_host_key" {
  algorithm = "ED25519"
}

resource "onepassword_item" "containerssh_host_key" {
  vault    = data.onepassword_vault.kubernetes.uuid
  title    = "containerssh-host-key"
  category = "secure_note"

  section {
    label = "ssh host key"

    field {
      label = "host.key"
      type  = "CONCEALED"
      value = tls_private_key.containerssh_host_key.private_key_openssh
    }
  }
}

resource "random_password" "grafana_admin_credentials" {
  length           = 40
  special          = true
  override_special = "!@#$%^&*()_+"
}

resource "onepassword_item" "grafana_admin_credentials" {
  vault    = data.onepassword_vault.kubernetes.uuid
  title    = "grafana-admin-credentials"
  category = "secure_note"

  section {
    label = "Grafana admin user"

    field {
      label = "GF_SECURITY_ADMIN_USER"
      type  = "STRING"
      value = "admin"
    }

    field {
      label = "GF_SECURITY_ADMIN_PASSWORD"
      type  = "CONCEALED"
      value = random_password.grafana_admin_credentials.result
    }
  }
}

resource "random_password" "vmetrics_admin_token" {
  length  = 40
  special = false
}

resource "onepassword_item" "vmetrics_admin_token" {
  for_each = { for vault in [data.onepassword_vault.kubernetes, data.onepassword_vault.tf_dev, data.onepassword_vault.tf_prod] : vault.name => vault }
  vault    = each.value.uuid
  title    = "vmetrics_admin_token"
  category = "secure_note"

  section {
    label = "Victoria Metrics admin token"

    field {
      label = "token"
      type  = "CONCEALED"
      value = random_password.vmetrics_admin_token.result
    }
  }
}

resource "random_password" "vmetrics_write_token" {
  length  = 40
  special = false
}

moved {
  to   = random_password.vmetrics_write_token
  from = random_password.cf_workers_metrics_token
}

resource "onepassword_item" "vmetrics_write_token" {
  for_each = { for vault in [data.onepassword_vault.kubernetes, data.onepassword_vault.tf_dev, data.onepassword_vault.tf_prod] : vault.name => vault }
  vault    = each.value.uuid
  title    = "vmetrics_write_token"
  category = "secure_note"

  section {
    label = "Victoria Metrics write token"

    field {
      label = "token"
      type  = "CONCEALED"
      value = random_password.vmetrics_write_token.result
    }
  }
}

resource "random_password" "vmetrics_read_token" {
  length  = 40
  special = false
}

resource "onepassword_item" "vmetrics_read_token" {
  for_each = { for vault in [data.onepassword_vault.kubernetes, data.onepassword_vault.tf_dev, data.onepassword_vault.tf_prod] : vault.name => vault }
  vault    = each.value.uuid
  title    = "vmetrics_read_token"
  category = "secure_note"

  section {
    label = "Victoria Metrics read token"

    field {
      label = "token"
      type  = "CONCEALED"
      value = random_password.vmetrics_read_token.result
    }
  }
}

resource "random_password" "bot_github_webhook_slug" {
  length  = 40
  special = false
}

resource "onepassword_item" "bot_github_webhook_slug" {
  vault    = data.onepassword_vault.kubernetes.uuid
  title    = "bot-github-webhook-slug"
  category = "secure_note"

  section {
    label = "Github webhook slug for the bot"

    field {
      label = "GITHUB_SLUG"
      type  = "CONCEALED"
      value = random_password.bot_github_webhook_slug.result
    }
  }
}

resource "random_password" "hedgedoc_oauth_secret" {
  length  = 40
  special = false
}

resource "onepassword_item" "hedgedoc_oauth_secret" {
  vault    = data.onepassword_vault.kubernetes.uuid
  title    = "hedgedoc-oauth"
  category = "secure_note"

  section {
    label = "OAuth secret for hedgedoc"

    field {
      label = "CMD_OAUTH2_CLIENT_SECRET"
      type  = "CONCEALED"
      value = random_password.hedgedoc_oauth_secret.result
    }
  }
}

resource "random_password" "grafana_oauth_client_secret" {
  length  = 40
  special = false
}

resource "onepassword_item" "grafana_oauth_client_secret" {
  vault    = data.onepassword_vault.kubernetes.uuid
  title    = "grafana-oauth-client-secret"
  category = "secure_note"

  section {
    label = "OAuth secret for grafana"

    field {
      label = "GRAFANA_OAUTH_CLIENT_SECRET"
      type  = "CONCEALED"
      value = random_password.grafana_oauth_client_secret.result
    }
  }
}

resource "random_bytes" "outline_secret_key" {
  length = 32
}

resource "random_password" "outline_utils_secret" {
  length  = 40
  special = false
}

resource "random_password" "outline_oauth_client_secret" {
  length  = 40
  special = false
}

resource "onepassword_item" "outline_secret" {
  vault    = data.onepassword_vault.kubernetes.uuid
  title    = "outline-secret"
  category = "secure_note"

  section {
    label = "Outline secret"

    field {
      label = "SECRET_KEY"
      type  = "CONCEALED"
      value = random_bytes.outline_secret_key.hex
    }

    field {
      label = "UTILS_SECRET"
      type  = "CONCEALED"
      value = random_password.outline_utils_secret.result
    }

    field {
      label = "OIDC_CLIENT_SECRET"
      type  = "CONCEALED"
      value = random_password.outline_oauth_client_secret.result
    }
  }
}
