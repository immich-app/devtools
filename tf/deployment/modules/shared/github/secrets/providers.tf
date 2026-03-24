provider "github" {
  app_auth {
    id              = var.github_app_id
    installation_id = var.github_app_installation_id
    pem_file        = var.github_app_pem_file
  }
  owner             = var.github_owner
  parallel_requests = true
}

provider "onepassword" {
  url   = var.op_connect_url
  token = var.op_connect_token
}
