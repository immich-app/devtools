locals {
  dashed_app_name        = replace(var.app_name, "/[^a-zA-Z\\d]/", "-")
  dashed_domain          = replace(var.domain, "/[^a-zA-Z\\d]/", "-")
  app_name_prefix        = local.dashed_app_name == "root" ? "" : "${local.dashed_app_name}-"
  sanitised_project_name = "${local.app_name_prefix}${local.dashed_domain}-${var.env}"
}
