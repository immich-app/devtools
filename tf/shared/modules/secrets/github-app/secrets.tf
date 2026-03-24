locals {
  apps = flatten([
    for app_name in var.app_names : {
      name = "GITHUB_APP_${upper(app_name)}"
    }
  ])
}

resource "onepassword_item" "manual" {
  for_each = { for idx, secret in local.apps : secret.name => secret }

  vault    = data.onepassword_vault.manual.uuid
  title    = each.value.name
  category = "secure_note"

  note_value = "Github App with private key. Private key should be reformatted to have \\n instead of newlines."

  section {
    label = "GitHub App"
    field {
      label = "pem"
      value = "CHANGE_ME"
      type  = "CONCEALED"
    }
    field {
      label = "app_id"
      value = "CHANGE_ME"
    }
    field {
      label = "installation_id"
      value = "CHANGE_ME"
    }
    field {
      label = "owner"
      value = "CHANGE_ME"
    }
  }

  lifecycle {
    ignore_changes = [section[0]]
  }
}

data "external" "convert_certificate" {
  for_each = onepassword_item.manual

  program = ["bash", "${path.module}/convert_cert.sh"]

  query = {
    pem_value = each.value.section[0].field[0].value
  }
}

# Create new 1Password items with all certificate formats
resource "onepassword_item" "converted" {
  for_each = onepassword_item.manual

  vault    = data.onepassword_vault.tf.uuid
  title    = each.value.title
  category = "secure_note"

  note_value = "GitHub App with certificates in multiple formats"

  section {
    label = "GitHub App"
    field {
      label = "pkcs1"
      value = data.external.convert_certificate[each.key].result.pkcs1
      type  = "CONCEALED"
    }
    field {
      label = "pkcs8"
      value = data.external.convert_certificate[each.key].result.pkcs8
      type  = "CONCEALED"
    }
    field {
      label = "app_id"
      value = each.value.section[0].field[1].value
    }
    field {
      label = "installation_id"
      value = each.value.section[0].field[2].value
    }
    field {
      label = "owner"
      value = each.value.section[0].field[3].value
    }
  }

  depends_on = [
    data.external.convert_certificate,
  ]
}
