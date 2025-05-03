provider "grafana" {
  url  = var.grafana_url
  auth = var.grafana_token
}

provider "onepassword" {
  service_account_token = var.op_service_account_token
}

