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

resource "random_password" "vmetrics_data_admin_token" {
  length  = 40
  special = false
}

resource "onepassword_item" "vmetrics_data_admin_token" {
  for_each = { for vault in [data.onepassword_vault.kubernetes, data.onepassword_vault.tf_dev, data.onepassword_vault.tf_prod] : vault.name => vault }
  vault    = each.value.uuid
  title    = "vmetrics_data_admin_token"
  category = "secure_note"

  section {
    label = "Victoria Metrics admin token"

    field {
      label = "token"
      type  = "CONCEALED"
      value = random_password.vmetrics_data_admin_token.result
    }
  }
}

resource "random_password" "vmetrics_data_write_token" {
  length  = 40
  special = false
}

resource "onepassword_item" "vmetrics_data_write_token" {
  for_each = { for vault in [data.onepassword_vault.kubernetes, data.onepassword_vault.tf_dev, data.onepassword_vault.tf_prod] : vault.name => vault }
  vault    = each.value.uuid
  title    = "vmetrics_data_write_token"
  category = "secure_note"

  section {
    label = "Victoria Metrics write token"

    field {
      label = "token"
      type  = "CONCEALED"
      value = random_password.vmetrics_data_write_token.result
    }
  }
}

resource "random_password" "vmetrics_data_read_token" {
  length  = 40
  special = false
}

resource "onepassword_item" "vmetrics_data_read_token" {
  for_each = { for vault in [data.onepassword_vault.kubernetes, data.onepassword_vault.tf_dev, data.onepassword_vault.tf_prod] : vault.name => vault }
  vault    = each.value.uuid
  title    = "vmetrics_data_read_token"
  category = "secure_note"

  section {
    label = "Victoria Metrics read token"

    field {
      label = "token"
      type  = "CONCEALED"
      value = random_password.vmetrics_data_read_token.result
    }
  }
}

data "onepassword_item" "zitadel_profile_json" {
  vault = data.onepassword_vault.kubernetes.uuid
  title = "PUSHED_ZITADEL_IAC_ADMIN_SA"
}

resource "onepassword_item" "zitadel_profile_json" {
  vault    = data.onepassword_vault.tf.uuid
  title    = "ZITADEL_PROFILE_JSON"
  category = "password"

  password = data.onepassword_item.zitadel_profile_json.password
}
