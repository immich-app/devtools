module "yucca-manual-secrets" {
  source = "./shared/modules/secrets/manual"

  secrets = {
    global = [
      "TF_STATE_S3_ENDPOINT",
      "TF_STATE_S3_BUCKET",
      "TF_STATE_S3_REGION",
      "TF_STATE_S3_ACCESS_KEY",
      "TF_STATE_S3_SECRET_KEY",
      "OVH_APPLICATION_KEY",
      "OVH_APPLICATION_SECRET",
      "OVH_CONSUMER_KEY",
      "TAILSCALE_API_KEY",
      "TAILSCALE_TAILNET_ID",
      "CLOUDFLARE_ACCOUNT_ID",
      "CLOUDFLARE_API_TOKEN",
      "TAILSCALE_OAUTH_CLIENT_ID",
      "TAILSCALE_OAUTH_CLIENT_SECRET",
      "NETBOX_API_TOKEN",
      "NETBOX_URL",
      "POSTMARK_API_TOKEN"
    ]
    scoped = [
      "CUSTOMER_ZITADEL_DOMAIN",
      "CUSTOMER_ZITADEL_PROFILE_JSON",
      "CUSTOMER_ZITADEL_SMTP_HOST",
      "CUSTOMER_ZITADEL_SMTP_USER",
      "CUSTOMER_ZITADEL_SMTP_PASSWORD",
      "CUSTOMER_ZITADEL_SMTP_SENDER_ADDRESS",
      "HETZNER_WEBSERVICE_API_USER",
      "HETZNER_WEBSERVICE_API_PASSWORD",
      "NET_SWITCHES_TERRAFORM_SSH_PRIVATE_KEY",
      "HCLOUD_API_TOKEN"
    ]
  }
  global_vault      = "yucca_tf_manual"
  copy_global_vault = "yucca_tf"
  scoped_vaults = {
    "yucca_tf_prod_manual"    = "yucca_tf_prod"
    "yucca_tf_staging_manual" = "yucca_tf_staging"
    "yucca_tf_dev_manual"     = "yucca_tf_dev"
  }
}

moved {
  from = module.generated-secrets
  to   = module.yucca-generated-secrets
}

module "yucca-generated-secrets" {
  source = "./shared/modules/secrets/generated"

  secrets = {
    global = []
    scoped = []
  }

  global_vault = "yucca_tf"
  scoped_vaults = toset([
    "yucca_tf_prod",
    "yucca_tf_staging",
    "yucca_tf_dev",
  ])
}
