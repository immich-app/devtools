terraform {
  backend "pg" {
    schema_name = "prod_discord_community"
  }
  required_version = "~> 1.7"

  required_providers {
    discord = {
      source  = "registry.terraform.io/zp-forks/discord"
      version = "~> 3.0.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 2.1"
    }
  }
}

