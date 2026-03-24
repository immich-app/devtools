provider "grafana" {
  url  = var.grafana_url
  auth = var.grafana_token
}

provider "onepassword" {
  url   = var.op_connect_url
  token = var.op_connect_token
}

