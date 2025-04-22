resource "grafana_contact_point" "leadership_alerts" {
  name = "leadership-alerts"

  discord {
    url = data.terraform_remote_state.discord_state.outputs.leadership_alerts_grafana_webhook_url
  }
}

resource "grafana_contact_point" "team_alerts" {
  name = "team-alerts"

  discord {
    url = data.terraform_remote_state.discord_state.outputs.team_alerts_grafana_webhook_url
  }
}

module "monitoring_dashboards" {
  source = "./shared/modules/grafana"

  env             = var.env
  folder_name     = "Monitoring Dashboards"
  folder_exists   = false # Let the module create the folder
  dashboards_path = "${path.module}/dashboards"
}
