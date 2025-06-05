terraform {
  backend "pg" {
    schema_name = "prod_zitadel"
  }
  required_version = "~> 1.7"

  required_providers {
    zitadel = {
      source  = "zitadel/zitadel"
      version = "2.2.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 2.1"
    }
  }
}

