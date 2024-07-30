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

resource "random_password" "grafana_admin_user" {
  length           = 40
  special          = true
  override_special = "!@#$%^&*()_+"
}

resource "onepassword_item" "grafana_admin_user" {
  vault    = data.onepassword_vault.kubernetes.uuid
  title    = "grafana-admin-user"
  category = "password"
  password_recipe {
    length  = 40
    symbols = true
    letters = true
    digits  = true
  }

  section {
    label = "Grafana admin user"

    field {
      label = "GRAFANA_ADMIN_USER"
      type  = "STRING"
      value = "admin"
    }

    field {
      label = "GRAFANA_ADMIN_PASSWORD"
      type  = "CONCEALED"
      value = random_password.grafana_admin_user.result
    }
  }
}
