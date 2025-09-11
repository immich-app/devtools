locals {
  // Only include stage name in domain if its set
  domain_stage = var.stage == "" ? "" : "${var.stage}."
  // We don't include the environment name in the URL for prod
  domain_env = var.env == "prod" ? "" : "${var.env}."
  // Combine domain stage and environment, if stage is blank and env is prod, this will be an empty string
  domain_prefix   = "${local.domain_stage}${local.domain_env}"
  dashed_app_name = replace(var.app_name, "/[^a-zA-Z\\d]/", "-")
  domain_app_name = local.dashed_app_name == "root" ? "" : "${local.dashed_app_name}."
  // Example: buy.immich.app or buy.dev.immich.app or buy.pr-55.dev.immich.app
  fqdn = "${local.domain_app_name}${local.domain_prefix}${var.domain}"
}

output "fqdn" {
  value = local.fqdn
}
