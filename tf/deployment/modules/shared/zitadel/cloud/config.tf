terraform {
  backend "pg" {
    schema_name = "prod_zitadel_cloud_test"
  }
  required_version = "~> 1.7"

  required_providers {
    zitadel = {
      source  = "zitadel/zitadel"
      version = "3.3.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 2.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.19.1"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }
}

