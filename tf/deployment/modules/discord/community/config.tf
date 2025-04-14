terraform {
  backend "pg" {
    schema_name = "prod_discord_community"
  }
  required_version = "~> 1.7"

  required_providers {
    discord = {
      source  = "registry.terraform.io/Lucky3028/discord"
      version = "~> 2.0.1"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 2.1"
    }
  }
}

