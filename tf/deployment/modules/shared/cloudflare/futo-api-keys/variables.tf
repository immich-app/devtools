variable "futo_op_service_account_token" {
  description = "1Password service-account token for the FUTO account, used to read the FUTO Cloudflare root token from the shared_tf vault"
  sensitive   = true
}

variable "create_futo_network_dns_token" {
  description = <<-EOT
    Whether to create the futo.network-scoped DNS token. Requires FUTO_NETWORK_ZONE_ID to
    already exist in the shared_tf vault (published by the cloudflare/futo-account module).
    Set to false for the first apply on a fresh account / the initial rollout of this
    feature — before futo-account has published the zone ID — then set back to true.
  EOT
  type        = bool
  default     = true
}
