module "o11y-manual-secrets" {
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
      "1PASS_CONNECT_SERVER_CREDENTIALS_FILE",
      "1PASS_CONNECT_O11Y_SUPERUSER"
    ]
    scoped = [
      "1PASS_CONNECT_O11Y_READ",
    ]
  }
  global_vault      = "o11y_tf_manual"
  copy_global_vault = "o11y_tf"
  scoped_vaults = {
    "o11y_tf_prod_manual"    = "o11y_tf_prod"
    "o11y_tf_staging_manual" = "o11y_tf_staging"
    "o11y_tf_dev_manual"     = "o11y_tf_dev"
  }
}

module "o11y-generated-secrets" {
  source = "./shared/modules/secrets/generated"

  secrets = {
    global = [
      { name = "GRAFANA_ADMIN_PASSWORD" }
    ]
    scoped = []
  }

  global_vault = "o11y_tf"
  scoped_vaults = toset([
    "o11y_tf_prod",
    "o11y_tf_staging",
    "o11y_tf_dev",
  ])
}
