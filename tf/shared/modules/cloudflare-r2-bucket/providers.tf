terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 1.0"
    }
  }
}
