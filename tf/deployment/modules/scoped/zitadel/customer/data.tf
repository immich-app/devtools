data "onepassword_vault" "tf_env" {
  name = "yucca_tf_${var.env}"
}

# NOTE: CUSTOMER_ZITADEL_DOMAIN (the public auth.futo.cloud vanity domain) is
# intentionally not read here — this module connects to the instance via the
# stable <name>.zitadel.cloud base domain below. The vanity domain remains the
# public-facing auth URL consumed by app-side config.
data "onepassword_item" "customer_zitadel_base_domain" {
  vault = data.onepassword_vault.tf_env.uuid
  title = "CUSTOMER_ZITADEL_BASE_DOMAIN"
}

data "onepassword_item" "customer_zitadel_profile_json" {
  vault = data.onepassword_vault.tf_env.uuid
  title = "CUSTOMER_ZITADEL_PROFILE_JSON"
}

data "onepassword_item" "customer_zitadel_smtp_host" {
  vault = data.onepassword_vault.tf_env.uuid
  title = "CUSTOMER_ZITADEL_SMTP_HOST"
}

data "onepassword_item" "customer_zitadel_smtp_user" {
  vault = data.onepassword_vault.tf_env.uuid
  title = "CUSTOMER_ZITADEL_SMTP_USER"
}

data "onepassword_item" "customer_zitadel_smtp_password" {
  vault = data.onepassword_vault.tf_env.uuid
  title = "CUSTOMER_ZITADEL_SMTP_PASSWORD"
}

data "onepassword_item" "customer_zitadel_smtp_sender_address" {
  vault = data.onepassword_vault.tf_env.uuid
  title = "CUSTOMER_ZITADEL_SMTP_SENDER_ADDRESS"
}
