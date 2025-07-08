provider "github" {
  app_auth {
    id              = var.github_app_id
    installation_id = var.github_app_installation_id
    pem_file        = var.github_app_pem_file
  }
  owner = var.github_owner
}

provider "onepassword" {
  service_account_token = var.op_service_account_token
}
