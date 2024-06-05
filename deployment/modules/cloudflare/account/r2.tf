resource "cloudflare_r2_bucket" "tf_state_database_backups" {
  account_id = var.cloudflare_account_id
  name       = "tf-state-database-backups"
  location   = "weur"
}
