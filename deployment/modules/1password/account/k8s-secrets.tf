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
