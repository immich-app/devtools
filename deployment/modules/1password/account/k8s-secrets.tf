data "onepassword_vault" "opentofu" {
  name = "OpenTofu"
}

data "onepassword_vault" "kubernetes" {
  name = "Kubernetes"
}

resource "random_password" "containerssh_oauth_secret" {
  length           = 20
  special          = true
  override_special = "!@#$%^&*()_+"
}

resource "onepassword_item" "containerssh_oauth" {
  vault    = data.onepassword_vault.kubernetes.uuid
  title    = "containerssh-oauth"
  category = "secure_note"

  section {
    label = "oauth secret"

    field {
      label = "CONTAINERSSH_OAUTH_SECRET"
      type  = "CONCEALED"
      value = random_password.containerssh_oauth_secret.result
    }
  }
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
