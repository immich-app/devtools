module "yucca-manual-secrets" {
  source = "./shared/modules/secrets/manual"

  secrets = {
    global = [
      TF_STATE_S3_ENDPOINT,
      TF_STATE_S3_BUCKET,
      TF_STATE_S3_ACCESS_KEY,
      TF_STATE_S3_SECRET_KEY,
      OVH_APPLICATION_KEY,
      OVH_APPLICATION_SECRET,
      OVH_CONSUMER_KEY
    ]
    scoped            = []
    global_vault      = "yucca_tf_manual"
    copy_global_vault = "yucca_tf"
    scoped_vaults = {
      "yucca_tf_prod_manual"    = "yucca_tf_prod"
      "yucca_tf_staging_manual" = "yucca_tf_staging"
      "yucca_tf_dev_manual"     = "yucca_tf_dev"
    }
  }
}

module "generated-secrets" {
  source = "./shared/modules/secrets/generated"

  secrets = {
    global = [
    ]
    scoped = [
    ]
  }

  global_vault = "yucca_tf"
  scoped_vaults = toset([
    "yucca_tf_prod",
    "yucca_tf_staging",
    "yucca_tf_dev",
  ])
}

module "github-apps" {
  source = "./shared/modules/secrets/github-app"

  app_names = ["IMMICH_TOFU", "IMMICH_PUSH_O_MATIC", "IMMICH_READ_ONLY", "IMMICH_GITHUB_ACTION_CHECKS"]
}
