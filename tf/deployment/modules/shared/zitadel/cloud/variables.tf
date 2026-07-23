variable "tf_state_postgres_conn_str" {}

variable "op_connect_url" {}
variable "op_connect_token" {
  sensitive = true
}

variable "zitadel_profile_json" {}
variable "futo_zitadel_profile_json" {}

# The stable <name>.zitadel.cloud base host for the FUTO internal instance. Used
# for all API connections (provider, hosted-login + idp-link scripts) instead of
# the auth.internal.futo.org custom domain, which is a mutable alias.
variable "futo_zitadel_base_domain" {}

variable "users_data_file_path" {
  description = "The path to the JSON file containing user data. This path should be resolvable from the Terragrunt execution directory or be an absolute path."
  type        = string
}

variable "futo_internal_zitadel_github_client_id" {}
variable "futo_internal_zitadel_github_client_secret" {
  sensitive = true
}

variable "zitadel_gitlab_client_id" {}
variable "zitadel_gitlab_client_secret" {
  sensitive = true
}
variable "zitadel_gitlab_issuer" {
  description = "The base URL of the FUTO self-hosted GitLab instance"
}

variable "cloudflare_account_id" {}

variable "zitadel_actions_worker_dir" {
  description = "Absolute path to the zitadel-actions worker service directory (injected by terragrunt via get_repo_root()); its scripts/build.ts transpiles the TS worker for deployment."
  type        = string
}

variable "outline_role_sync_worker_dir" {
  description = "Absolute path to the outline-role-sync worker service directory (injected by terragrunt via get_repo_root()); its scripts/build.ts bundles the TS worker for deployment."
  type        = string
}

variable "futo_op_service_account_token" {}
