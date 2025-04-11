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

resource "null_resource" "convert_certificates" {
  for_each = onepassword_item.manual

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Extract PEM from 1Password section[0]
      PEM_VALUE=$(echo '${each.value.section[0].field[0].value}')

      # Create cert directory if it doesn't exist
      mkdir -p ${path.module}/certs

      if [ -z "$PEM_VALUE" ] || [ "$PEM_VALUE" = "CHANGE_ME" ]; then
        echo "PEM value not set or is still the default value. Using CHANGE_ME as certificate values."

        # Create certificate files with CHANGE_ME content
        echo "CHANGE_ME" > ${path.module}/certs/${each.key}_pkcs1.pem
        echo "CHANGE_ME" > ${path.module}/certs/${each.key}_pkcs8.pem
      else
        echo "Processing PEM value to handle newlines"

        # Convert literal \n to actual newlines and create PKCS#1 PEM file (original format)
        echo -e "$PEM_VALUE" > ${path.module}/certs/${each.key}_pkcs1.pem

        # Validate PKCS#1 format
        openssl rsa -in ${path.module}/certs/${each.key}_pkcs1.pem -check -noout
        PKCS1_VALID=$?

        if [ $PKCS1_VALID -ne 0 ]; then
          echo "Input PEM does not appear to be valid PKCS#1 format"
          exit 1
        fi

        # Convert to PKCS8
        openssl pkcs8 -topk8 -inform PEM -in ${path.module}/certs/${each.key}_pkcs1.pem -outform PEM -nocrypt > ${path.module}/certs/${each.key}_pkcs8.pem
        PKCS8_SUCCESS=$?

        # Verify files were created with content
        if [ ! -s ${path.module}/certs/${each.key}_pkcs1.pem ]; then
          echo "PKCS1 file is empty"
          exit 1
        fi

        if [ $PKCS8_SUCCESS -ne 0 ] || [ ! -s ${path.module}/certs/${each.key}_pkcs8.pem ]; then
          echo "PKCS8 conversion failed or file is empty"
          exit 1
        fi
      fi
    EOT
  }

  depends_on = [onepassword_item.manual]
}

# Read the converted certificate files
data "local_file" "pkcs1_cert" {
  for_each   = onepassword_item.manual
  filename   = "${path.module}/certs/${each.key}_pkcs1.pem"
  depends_on = [null_resource.convert_certificates]
}

data "local_file" "pkcs8_cert" {
  for_each   = onepassword_item.manual
  filename   = "${path.module}/certs/${each.key}_pkcs8.pem"
  depends_on = [null_resource.convert_certificates]
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
      value = data.local_file.pkcs1_cert[each.key].content
      type  = "CONCEALED"
    }
    field {
      label = "pkcs8"
      value = data.local_file.pkcs8_cert[each.key].content
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
    data.local_file.pkcs1_cert,
    data.local_file.pkcs8_cert,
    null_resource.convert_certificates
  ]
}
