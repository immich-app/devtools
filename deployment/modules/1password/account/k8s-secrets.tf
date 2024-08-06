data "onepassword_vault" "opentofu" {
  name = "OpenTofu"
}

data "onepassword_vault" "kubernetes" {
  name = "Kubernetes"
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

resource "random_password" "cf_workers_metrics_token" {
  length           = 40
  special          = true
  override_special = "!@#$%^&*()_+"
}

resource "onepassword_item" "cf_workers_metrics_token" {
  vault    = data.onepassword_vault.kubernetes.uuid
  title    = "cf-workers-metrics-token"
  category = "secure_note"

  section {
    label = "Cloudflare workers metrics write token"

    field {
      label = "token"
      type  = "CONCEALED"
      value = random_password.cf_workers_metrics_token.result
    }
  }
}
