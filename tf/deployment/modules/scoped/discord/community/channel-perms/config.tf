terraform {
  required_version = "~> 1.7"

  required_providers {
    discord = {
      source  = "registry.terraform.io/zp-forks/discord"
      version = "~> 3"
    }
  }
}

