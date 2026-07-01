terraform {
  backend "pg" {}
  required_version = "~> 1.7"

  required_providers {
    zitadel = {
      source  = "zitadel/zitadel"
      version = "2.12.8"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.21.1"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 2.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}
