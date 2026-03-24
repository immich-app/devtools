variable "github_app_id" {}
variable "github_app_installation_id" {}
variable "github_app_pem_file" {}
variable "github_owner" {}

variable "op_connect_url" {}
variable "op_connect_token" {
  sensitive = true
}
