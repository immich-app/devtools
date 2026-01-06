terraform {
  backend "pg" {}
  required_version = "~> 1.7"

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "3.25.9"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 3.0"
    }
  }
}


