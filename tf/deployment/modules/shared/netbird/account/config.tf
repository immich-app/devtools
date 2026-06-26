terraform {
  backend "pg" {
    schema_name = "prod_netbird_account"
  }
  required_version = "~> 1.7"

  required_providers {
    netbird = {
      source  = "netbirdio/netbird"
      version = "0.0.9"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 2.1"
    }
  }
}
