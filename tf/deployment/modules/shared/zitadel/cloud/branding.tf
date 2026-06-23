// FUTO brand palette, sourced from futo.tech design tokens:
//   primary  = accent-blue-400   (#3c9eea)
//   warn     = accent-yellow-400 (#f2b859)
//   bg dark  = neutral-blue-950  (#02070a)
//   font dk  = neutral-blue-200  (#cfeaff)
//
// This is FUTO's *internal* instance, so it is distinguished from the
// customer-facing instances two ways: the primary accent is the FUTO amber
// (#f2b859) rather than blue (which carries into the console, not just login),
// and the logo carries an amber "INTERNAL" badge so the login screen says so
// explicitly (common.title only sets the browser tab title in the v2 UI).
resource "zitadel_default_label_policy" "default" {
  primary_color    = "#f2b859"
  warn_color       = "#f2b859"
  background_color = "#ffffff"
  font_color       = "#02070a"

  primary_color_dark    = "#f2b859"
  warn_color_dark       = "#f2b859"
  background_color_dark = "#02070a"
  font_color_dark       = "#cfeaff"

  hide_login_name_suffix = true
  disable_watermark      = true
  theme_mode             = "THEME_MODE_AUTO"

  logo_path = "${path.module}/assets/logo.svg"
  logo_hash = filemd5("${path.module}/assets/logo.svg")

  logo_dark_path = "${path.module}/assets/logo.svg"
  logo_dark_hash = filemd5("${path.module}/assets/logo.svg")

  icon_path = "${path.module}/assets/icon.svg"
  icon_hash = filemd5("${path.module}/assets/icon.svg")

  icon_dark_path = "${path.module}/assets/icon.svg"
  icon_dark_hash = filemd5("${path.module}/assets/icon.svg")

  set_active = true
}

resource "zitadel_default_privacy_policy" "default" {
  tos_link      = "https://futo.tech/terms"
  privacy_link  = "https://futo.tech/privacy"
  help_link     = "https://futo.tech/help"
  support_email = "support@futo.tech"
}

// The ZITADEL terraform provider does not expose SettingsService.
// SetHostedLoginTranslation (used by the v2 hosted login UI), so the "FUTO
// Internal" login-title override is pushed via the same local-exec script the
// customer module uses, keyed on a content hash so it only re-runs on change.
locals {
  hosted_login_translations_file   = "${path.module}/translations/en.json"
  hosted_login_translations_script = "${path.module}/scripts/set-hosted-login-translations.sh"
  hosted_login_translations_domain = "auth.internal.futo.org"
  hosted_login_translations_locale = "en"
}

resource "terraform_data" "hosted_login_translations" {
  triggers_replace = [
    filemd5(local.hosted_login_translations_file),
    filemd5(local.hosted_login_translations_script),
    local.hosted_login_translations_domain,
    local.hosted_login_translations_locale,
  ]

  provisioner "local-exec" {
    command = local.hosted_login_translations_script

    environment = {
      ZITADEL_DOMAIN       = local.hosted_login_translations_domain
      ZITADEL_PROFILE_JSON = var.futo_zitadel_profile_json
      TRANSLATIONS_FILE    = local.hosted_login_translations_file
      LOCALE               = local.hosted_login_translations_locale
    }
  }

  depends_on = [zitadel_default_label_policy.default]
}
