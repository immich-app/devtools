variable "cloudflare_api_token" {}
variable "cloudflare_account_id" {}

variable "app_name" {}
variable "env" {
  default = "prod"
}
variable "stage" {
  default = "main"
}
variable "domain" {
  default = "immich.app"
}
variable "pages_project" {
  type = object({
    name      = string
    subdomain = string
  })
}
