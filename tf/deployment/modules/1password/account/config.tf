terraform {
  backend "pg" {
    schema_name = "prod_1password_account"
  }
  required_version = "~> 1.7"

  required_providers {
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
    htpasswd = {
      source = "loafoe/htpasswd"
      version = "1.2.1"
    }
  }
}
