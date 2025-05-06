resource "grafana_contact_point" "leadership_alerts" {
  name = "leadership-alerts"

  discord {
    url     = data.terraform_remote_state.discord_state.outputs.leadership_alerts_grafana_webhook_url
    message = "{{ template \"discord.message\" . }}"
    title   = "{{ template \"discord.title\" . }}"
  }
}

resource "grafana_contact_point" "team_alerts" {
  name = "team-alerts"

  discord {
    url     = data.terraform_remote_state.discord_state.outputs.team_alerts_grafana_webhook_url
    message = "{{ template \"discord.message\" . }}"
    title   = "{{ template \"discord.title\" . }}"
  }
}

resource "grafana_notification_policy" "default" {
  contact_point   = grafana_contact_point.team_alerts.name
  group_by        = ["alertname"]
  group_interval  = "1m"
  group_wait      = "0s"
  repeat_interval = "1h"

  policy {
    matcher {
      label = "channel"
      match = "="
      value = "team"
    }
    contact_point = grafana_contact_point.team_alerts.name
  }

  policy {
    matcher {
      label = "channel"
      match = "="
      value = "leadership"
    }
    contact_point = grafana_contact_point.leadership_alerts.name
  }
}

module "example_dashboards" {
  # source = "/home/zack/Source/immich/devtools/tf/shared/modules/grafana"
  source = "git::https://github.com/immich-app/devtools.git//tf/shared/modules/grafana?ref=main"

  env             = var.env
  folder_name     = "Example TF Dashboard"
  folder_exists   = false # Let the module create the folder
  dashboards_path = "${path.module}/dashboards"
}

