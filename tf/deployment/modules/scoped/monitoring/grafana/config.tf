terraform {
  backend "pg" {}
  required_version = "~> 1.7"

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "4.20.1"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 2.1"
    }
  }
}


