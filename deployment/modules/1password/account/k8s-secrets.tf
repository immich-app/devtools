data "onepassword_vault" "opentofu" {
  name = "OpenTofu"
}

data "onepassword_vault" "kubernetes" {
  name = "Kubernetes"
}

resource "random_password" "example_k8s_password_gen_string_2" {
  length           = 20
  special          = true
  override_special = "!@#$%^&*()_+"
}

resource "onepassword_item" "example_k8s_password_gen" {
  vault    = data.onepassword_vault.kubernetes.uuid
  title    = "example-terraform-k8s-password-gen"
  category = "password"
  password_recipe {
    length  = 40
    symbols = true
    letters = true
    digits  = true
  }

  section {
    label = "Example custom section for terraform k8s vault item"

    field {
      label = "string-field"
      type  = "STRING"
      value = "example"
    }

    field {
      label = "string-field-generated"
      type  = "STRING"
      value = random_password.example_k8s_password_gen_string_2.result
    }
  }
}
