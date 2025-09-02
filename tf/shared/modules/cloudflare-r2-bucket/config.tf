terraform {
  required_version = "~> 1.7"

  required_providers {
    cloudflare = {
      source                = "cloudflare/cloudflare"
      version               = "~> 5"
      configuration_aliases = [cloudflare.api_keys]
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 2.1"
    }
  }
}
