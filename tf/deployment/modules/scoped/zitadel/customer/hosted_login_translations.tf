locals {
  hosted_login_translations_file   = "${path.module}/translations/en.json"
  hosted_login_translations_script = "${path.module}/scripts/set-hosted-login-translations.sh"
  hosted_login_translations_locale = "en"
}

// The ZITADEL terraform provider (v2.12 and earlier) does not expose the
// SettingsService.SetHostedLoginTranslation endpoint used by the v2 hosted
// login UI. Push those overrides via a local-exec script, keyed on a content
// hash so it only re-runs when translations, domain, or locale change.
resource "null_resource" "hosted_login_translations" {
  triggers = {
    translations_hash = filemd5(local.hosted_login_translations_file)
    script_hash       = filemd5(local.hosted_login_translations_script)
    domain            = data.onepassword_item.customer_zitadel_domain.password
    locale            = local.hosted_login_translations_locale
  }

  provisioner "local-exec" {
    command = local.hosted_login_translations_script

    environment = {
      ZITADEL_DOMAIN       = data.onepassword_item.customer_zitadel_domain.password
      ZITADEL_PROFILE_JSON = data.onepassword_item.customer_zitadel_profile_json.password
      TRANSLATIONS_FILE    = local.hosted_login_translations_file
      LOCALE               = local.hosted_login_translations_locale
    }
  }

  depends_on = [zitadel_instance_restrictions.default]
}
