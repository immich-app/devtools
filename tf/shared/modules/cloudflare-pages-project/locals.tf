locals {
  app_name = replace(var.app_name, "/[^a-zA-Z\\d]/", "-")
  dashed_domain = replace(var.domain, "/[^a-zA-Z\\d]/", "-")
  sanitised_project_name = "${local.app_name}-${local.dashed_domain}-${var.env}"
}
