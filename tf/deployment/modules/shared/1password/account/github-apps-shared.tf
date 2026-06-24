// Mirror the github app converted credentials into the FUTO shared_tf vault,
// alongside the immich tf copies the github-app module writes. Sourced from the
// module's outputs so the shared module stays single-account/generic.
//
// for_each keys off the (non-sensitive) app titles rather than the certificates
// map itself, because that output is sensitive and can't drive for_each.
data "onepassword_vault" "shared_tf" {
  provider = onepassword.futo
  name     = "shared_tf"
}

resource "onepassword_item" "github_app_shared" {
  provider = onepassword.futo
  for_each = toset([for name in local.github_app_names : "GITHUB_APP_${upper(name)}"])

  vault    = data.onepassword_vault.shared_tf.uuid
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
