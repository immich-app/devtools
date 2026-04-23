resource "zitadel_smtp_config" "default" {
  sender_address = data.onepassword_item.customer_zitadel_smtp_sender_address.password
  sender_name    = "FUTO"
  tls            = true
  host           = data.onepassword_item.customer_zitadel_smtp_host.password
  user           = data.onepassword_item.customer_zitadel_smtp_user.password
  password       = data.onepassword_item.customer_zitadel_smtp_password.password

  set_active = true
}
