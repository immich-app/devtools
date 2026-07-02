module "shared-manual-secrets" {
  source = "./shared/modules/secrets/manual"

  secrets = {
    global = [
      "NETBIRD_TF_PAT",
      "CLOUDFLARE_ACCOUNT_ID",
      "CLOUDFLARE_API_TOKEN",
      "BUNNY_API_KEY",
    ]
    scoped = []
  }
  global_vault      = "shared_tf_manual"
  copy_global_vault = "shared_tf"
  scoped_vaults = {
    "shared_tf_prod_manual"    = "shared_tf_prod"
    "shared_tf_staging_manual" = "shared_tf_staging"
    "shared_tf_dev_manual"     = "shared_tf_dev"
  }
}

module "shared-generated-secrets" {
  source = "./shared/modules/secrets/generated"

  secrets = {
    global = []
    scoped = [
      { name = "O11Y_VICTORIAMETRICS_VMAUTH_PASSWORD" },
    ]
  }

  global_vault = "shared_tf"
  scoped_vaults = toset([
    "shared_tf_prod",
    "shared_tf_staging",
    "shared_tf_dev",
  ])
}
