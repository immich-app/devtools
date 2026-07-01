terraform {
  backend "pg" {
    schema_name = "prod_bunny_futo_account"
  }
  required_version = "~> 1.7"

  required_providers {
    bunnynet = {
      source  = "BunnyWay/bunnynet"
      version = "~> 0.15"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 2.0"
    }
  }
}
