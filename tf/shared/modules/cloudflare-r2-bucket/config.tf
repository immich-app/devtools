terraform {
  required_version = "~> 1.7"

  required_providers {
    cloudflare = {
      source                = "cloudflare/cloudflare"
      version               = "~> 4.46"
      configuration_aliases = [cloudflare.api_keys]
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 3.0"
    }
  }
}
