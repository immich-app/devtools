// Migration step 1: copy every secret currently in the immich Connect vaults
// (tf, tf_prod, tf_staging, tf_dev) into dedicated immich_tf* vaults in the FUTO
// account, preserving exact values. Consumers are untouched here — they still
// read the immich vaults and get transitioned one at a time in a later step,
// after which the immich-side copies are removed. Same dual-write pattern as
// github-apps-shared.tf: the default provider owns the immich items, the
// onepassword.futo alias writes the FUTO copies.
//
// PREREQUISITE: the immich_tf* vaults must already exist in the FUTO account and
// be granted to the FUTO terraform service account — the provider can't create
// vaults (there is no onepassword_vault resource).

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

locals {
  // immich (source) vault name -> FUTO destination vault uuid
  futo_vault_by_src = {
    tf         = data.onepassword_vault.immich_tf.uuid
    tf_prod    = data.onepassword_vault.immich_tf_prod.uuid
    tf_staging = data.onepassword_vault.immich_tf_staging.uuid
    tf_dev     = data.onepassword_vault.immich_tf_dev.uuid
  }

  // VictoriaMetrics tokens live in tf_dev + tf_prod as secure_notes with a
  // single "token" field (see k8s-secrets.tf). Build non-sensitive metadata for
  // for_each; the token value is looked up by kind inside the resource.
  futo_vmetrics_meta = {
    for entry in flatten([
      for env in [
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

// VictoriaMetrics tokens (tf_dev, tf_prod) -> immich_tf_dev / immich_tf_prod.
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
