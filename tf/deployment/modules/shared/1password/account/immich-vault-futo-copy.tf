// Migration step 1: copy every secret currently in the immich Connect vaults
// (tf, tf_prod, tf_staging, tf_dev, Kubernetes) into immich_-prefixed vaults in
// the FUTO account, preserving exact values. Consumers are untouched here — they
// still read the immich vaults and get transitioned one at a time in a later
// step, after which the immich-side copies are removed. Same dual-write pattern
// as github-apps-shared.tf: the default provider owns the immich items, the
// onepassword.futo alias writes the FUTO copies.
//
// Vault mapping: tf -> immich_tf, tf_<env> -> immich_tf_<env>,
// Kubernetes -> immich_kubernetes.
//
// PREREQUISITE: the immich_* vaults must already exist in the FUTO account and
// be granted to the FUTO terraform service account — the provider can't create
// vaults (there is no onepassword_vault resource).
//
// NOTE: this only covers items terraform knows about. Anything in the Kubernetes
// vault created outside terraform (other than PUSHED_ZITADEL_IAC_ADMIN_SA, which
// is read below) has to be moved by hand.

data "onepassword_vault" "immich_tf" {
  provider = onepassword.futo
  name     = "immich_tf"
}

data "onepassword_vault" "immich_tf_prod" {
  provider = onepassword.futo
  name     = "immich_tf_prod"
}

data "onepassword_vault" "immich_tf_staging" {
  provider = onepassword.futo
  name     = "immich_tf_staging"
}

data "onepassword_vault" "immich_tf_dev" {
  provider = onepassword.futo
  name     = "immich_tf_dev"
}

data "onepassword_vault" "immich_kubernetes" {
  provider = onepassword.futo
  name     = "immich_kubernetes"
}

locals {
  // immich (source) vault name -> FUTO destination vault uuid
  futo_vault_by_src = {
    tf         = data.onepassword_vault.immich_tf.uuid
    tf_prod    = data.onepassword_vault.immich_tf_prod.uuid
    tf_staging = data.onepassword_vault.immich_tf_staging.uuid
    tf_dev     = data.onepassword_vault.immich_tf_dev.uuid
  }

  // VictoriaMetrics tokens live in Kubernetes + tf_dev + tf_prod as secure_notes
  // with a single "token" field (see k8s-secrets.tf). Build non-sensitive
  // metadata for for_each; the token value is looked up by kind inside the
  // resource.
  futo_vmetrics_meta = {
    for entry in flatten([
      for env in [
        { vault_name = "kubernetes", vault_uuid = data.onepassword_vault.immich_kubernetes.uuid },
        { vault_name = "tf_dev", vault_uuid = data.onepassword_vault.immich_tf_dev.uuid },
        { vault_name = "tf_prod", vault_uuid = data.onepassword_vault.immich_tf_prod.uuid },
        ] : [
        for kind in ["admin", "write", "read"] : {
          key   = "${env.vault_name}_${kind}"
          title = "vmetrics_data_${kind}_token"
          label = "Victoria Metrics ${kind} token"
          vault = env.vault_uuid
          kind  = kind
        }
      ]
    ]) : entry.key => entry
  }
}

// Manual secrets (human-entered) -> immich_tf*
resource "onepassword_item" "immich_futo_manual_copy" {
  provider = onepassword.futo
  for_each = module.manual-secrets.secret_meta

  vault    = local.futo_vault_by_src[each.value.vault_name]
  title    = each.value.title
  category = "password"
  password = module.manual-secrets.secret_values[each.key]
}

// Generated secrets (random_password) -> immich_tf*, by exact current value.
resource "onepassword_item" "immich_futo_generated_copy" {
  provider = onepassword.futo
  for_each = module.generated-secrets.secret_meta

  vault    = local.futo_vault_by_src[each.value.vault_name]
  title    = each.value.title
  category = "password"
  password = module.generated-secrets.secret_values[each.key]
}

// Standalone ZITADEL_PROFILE_JSON (tf) -> immich_tf.
resource "onepassword_item" "immich_futo_zitadel_profile_copy" {
  provider = onepassword.futo

  vault    = data.onepassword_vault.immich_tf.uuid
  title    = "ZITADEL_PROFILE_JSON"
  category = "password"
  password = data.onepassword_item.zitadel_profile_json.password
}

// GitHub App converted credentials (tf) -> immich_tf. Mirrors
// github-apps-shared.tf, sourcing the module's certificates output.
resource "onepassword_item" "immich_futo_github_app_copy" {
  provider = onepassword.futo
  for_each = toset([for name in local.github_app_names : "GITHUB_APP_${upper(name)}"])

  vault    = data.onepassword_vault.immich_tf.uuid
  title    = each.key
  category = "secure_note"

  note_value = "GitHub App with certificates in multiple formats"

  section {
    label = "GitHub App"
    field {
      label = "pkcs1"
      value = module.github-apps.certificates[each.key].pkcs1
      type  = "CONCEALED"
    }
    field {
      label = "pkcs8"
      value = module.github-apps.certificates[each.key].pkcs8
      type  = "CONCEALED"
    }
    field {
      label = "app_id"
      value = module.github-apps.certificates[each.key].app_id
    }
    field {
      label = "installation_id"
      value = module.github-apps.certificates[each.key].installation_id
    }
    field {
      label = "owner"
      value = module.github-apps.certificates[each.key].owner
    }
  }
}

// ContainerSSH host key (Kubernetes) -> immich_kubernetes.
resource "onepassword_item" "immich_futo_containerssh_host_key_copy" {
  provider = onepassword.futo

  vault    = data.onepassword_vault.immich_kubernetes.uuid
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

// Grafana admin credentials (Kubernetes) -> immich_kubernetes.
resource "onepassword_item" "immich_futo_grafana_admin_credentials_copy" {
  provider = onepassword.futo

  vault    = data.onepassword_vault.immich_kubernetes.uuid
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

// The zitadel IaC service-account JSON is pushed into the Kubernetes vault out
// of band (terraform only reads it via data.onepassword_item), but it still has
// to land in immich_kubernetes for the vault to be fully migrated.
resource "onepassword_item" "immich_futo_zitadel_iac_admin_sa_copy" {
  provider = onepassword.futo

  vault    = data.onepassword_vault.immich_kubernetes.uuid
  title    = "PUSHED_ZITADEL_IAC_ADMIN_SA"
  category = "password"
  password = data.onepassword_item.zitadel_profile_json.password
}

// VictoriaMetrics tokens (Kubernetes, tf_dev, tf_prod) -> immich_kubernetes /
// immich_tf_dev / immich_tf_prod.
resource "onepassword_item" "immich_futo_vmetrics_copy" {
  provider = onepassword.futo
  for_each = local.futo_vmetrics_meta

  vault    = each.value.vault
  title    = each.value.title
  category = "secure_note"

  section {
    label = each.value.label
    field {
      label = "token"
      type  = "CONCEALED"
      value = (
        each.value.kind == "admin" ? random_password.vmetrics_data_admin_token.result :
        each.value.kind == "write" ? random_password.vmetrics_data_write_token.result :
        random_password.vmetrics_data_read_token.result
      )
    }
  }
}
