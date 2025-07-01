output "bucket" {
  value = {
    id         = cloudflare_r2_bucket.bucket.id
    name       = cloudflare_r2_bucket.bucket.name
    account_id = cloudflare_r2_bucket.bucket.account_id
    location   = cloudflare_r2_bucket.bucket.location
  }
  description = "The details of the created R2 bucket"
}

output "api_token_id" {
  value       = cloudflare_api_token.bucket_api_token.id
  description = "The ID of the generated API token"
  sensitive   = true
}

output "api_token_value" {
  value       = cloudflare_api_token.bucket_api_token.value
  description = "The value of the generated API token"
  sensitive   = true
}

output "onepassword_item_id" {
  value       = onepassword_item.bucket_credentials.id
  description = "The ID of the created 1Password item"
}