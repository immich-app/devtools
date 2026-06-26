data "onepassword_vault" "shared_tf" {
  name = "shared_tf"
}

# NetBird Personal Access Token, populated in the FUTO shared_tf vault by the
# 1password/futo-account module (shared-manual-secrets -> NETBIRD_TF_PAT).
data "onepassword_item" "netbird_pat" {
  vault = data.onepassword_vault.shared_tf.uuid
  title = "NETBIRD_TF_PAT"
}
