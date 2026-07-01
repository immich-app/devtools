data "onepassword_vault" "shared_tf" {
  name = "shared_tf"
}

data "onepassword_item" "bunny_api_key" {
  vault = data.onepassword_vault.shared_tf.uuid
  title = "BUNNY_API_KEY"
}
