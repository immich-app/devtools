resource "grafana_folder" "folder" {
  count = var.folder_exists ? 0 : 1
  title = var.folder_name
  uid   = replace(lower(var.folder_name), "/[^a-z\\d]/", "-")
}

data "grafana_folder" "folder" {
  depends_on = [grafana_folder.folder]
  title      = var.folder_name
}

locals {
  # Find all .json files in the provided path, if the path is not null
  dashboard_files = var.dashboards_path != null ? fileset(var.dashboards_path, "**/*.json") : []
}

resource "grafana_dashboard" "dashboards" {
  for_each    = toset(local.dashboard_files)
  folder      = data.grafana_folder.folder.id
  config_json = file("${var.dashboards_path}/${each.value}")

  # Overwrite existing dashboards with the same name
  overwrite = true
}
