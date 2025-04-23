terraform {
  backend "pg" {
    schema_name = "dev_monitoring_grafana"
  }
  required_version = "~> 1.7"

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "3.22.3"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 2.1"
    }
  }
}


