terraform {
  backend "pg" {
    schema_name = "prod_cloudflare_account"
  }
  required_version = "~> 1.7"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.52.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 2.0"
    }
  }
}
