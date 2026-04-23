// FUTO brand palette, sourced from futo.tech design tokens:
//   primary  = accent-blue-400   (#3c9eea)
//   warn     = accent-yellow-400 (#f2b859)
//   bg dark  = neutral-blue-950  (#02070a)
//   font dk  = neutral-blue-200  (#cfeaff)
resource "zitadel_default_label_policy" "default" {
  primary_color    = "#3c9eea"
  warn_color       = "#f2b859"
  background_color = "#ffffff"
  font_color       = "#02070a"

  primary_color_dark    = "#3c9eea"
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

  icon_path = "${path.module}/assets/icon.png"
  icon_hash = filemd5("${path.module}/assets/icon.png")

  icon_dark_path = "${path.module}/assets/icon.png"
  icon_dark_hash = filemd5("${path.module}/assets/icon.png")

  set_active = true
}

resource "zitadel_default_privacy_policy" "default" {
  tos_link      = "https://futo.tech/terms"
  privacy_link  = "https://futo.tech/privacy"
  help_link     = "https://futo.tech/help"
  support_email = "support@futo.tech"
}
