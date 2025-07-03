locals {
  // Cloudflare pages requires a branch name
  // This determines whether the deployment is production or staging
  // In our case we deploy to the "prod" production branch only for production environment with no stage
  // This automatically resolves if we combine stage and env
  unsanitised_pages_branch = "${var.stage}${var.env}"
  pages_branch             = replace(local.unsanitised_pages_branch, "/[^a-zA-Z\\d]/", "-")
  pages_url_prefix         = local.pages_branch == "prod" ? "" : "${local.pages_branch}."
}
