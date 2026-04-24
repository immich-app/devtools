resource "zitadel_default_login_policy" "default" {
  user_login                    = true
  allow_register                = true
  allow_external_idp            = true
  force_mfa                     = false
  force_mfa_local_only          = false
  passwordless_type             = "PASSWORDLESS_TYPE_ALLOWED"
  hide_password_reset           = false
  password_check_lifetime       = "24h0m0s"
  external_login_check_lifetime = "168h0m0s"
  multi_factor_check_lifetime   = "12h0m0s"
  mfa_init_skip_lifetime        = "720h0m0s"
  second_factor_check_lifetime  = "12h0m0s"
  ignore_unknown_usernames      = true
  default_redirect_uri          = ""
  second_factors                = ["SECOND_FACTOR_TYPE_OTP", "SECOND_FACTOR_TYPE_U2F"]
  multi_factors                 = ["MULTI_FACTOR_TYPE_U2F_WITH_VERIFICATION"]
  idps                          = []
  allow_domain_discovery        = false
  disable_login_with_email      = false
  disable_login_with_phone      = true
}

resource "zitadel_default_password_complexity_policy" "default" {
  min_length    = 10
  has_uppercase = true
  has_lowercase = true
  has_number    = true
  has_symbol    = false
}

resource "zitadel_default_lockout_policy" "default" {
  max_password_attempts = 10
}

resource "zitadel_default_domain_policy" "default" {
  user_login_must_be_domain                   = false
  validate_org_domains                        = false
  smtp_sender_address_matches_instance_domain = false
}

resource "zitadel_default_oidc_settings" "default" {
  access_token_lifetime         = "1h0m0s"
  id_token_lifetime             = "1h0m0s"
  refresh_token_expiration      = "2160h0m0s"
  refresh_token_idle_expiration = "720h0m0s"
}

resource "zitadel_default_notification_policy" "default" {
  password_change = true
}

resource "zitadel_instance_restrictions" "default" {
  allowed_languages                = ["en"]
  disallow_public_org_registration = true
}

// login_default_org: without this, the v2 hosted login UI can't resolve an
// org when a user reaches the login/reset URL directly (no OIDC authRequest
// context) and the RSC render errors. This makes the UI fall back to
// zitadel_org.customers.
//
// login_v2.required: route every customer app through the new v2 hosted login
// UI regardless of the application's own login_version preference. The v2 UI
// is what actually prompts users to register a passkey after first login and
// hosts our custom translations; the v1 UI silently ignores both.
resource "zitadel_instance_features" "default" {
  login_default_org = true

  login_v2 {
    required = true
    base_uri = "${data.onepassword_item.customer_zitadel_domain.password}/ui/v2/login"
  }
}

// ZITADEL's default email-code expiries are tight (minutes). Give customers
// more breathing room on the codes they receive by email.
//
// Note on the include_* flags: the zitadel_instance_secret_generator resource
// in v2.11 / v2.12 has a bug where explicit `false` bool values are silently
// dropped on create (the provider guards each field with d.HasChange(...),
// and HasChange returns false when the new config value matches the Go zero
// value — bool false). We therefore set include_lower_letters /
// include_upper_letters / include_digits to `true` — changes get detected
// and applied. include_symbols stays at the server default (false) because
// the buggy override-skip happens to produce the right outcome there.
resource "zitadel_instance_secret_generator" "verify_email_code" {
  generator_type        = "verify_email_code"
  length                = 8
  expiry                = "1h"
  include_lower_letters = true
  include_upper_letters = true
  include_digits        = true
  include_symbols       = false
}

resource "zitadel_instance_secret_generator" "password_reset_code" {
  generator_type        = "password_reset_code"
  length                = 8
  expiry                = "1h"
  include_lower_letters = true
  include_upper_letters = true
  include_digits        = true
  include_symbols       = false
}

resource "zitadel_instance_secret_generator" "passwordless_init_code" {
  generator_type        = "passwordless_init_code"
  length                = 8
  expiry                = "1h"
  include_lower_letters = true
  include_upper_letters = true
  include_digits        = true
  include_symbols       = false
}

// First-time user init codes are mailed when an admin pre-creates an account;
// the recipient may not act immediately, so give them a few days.
resource "zitadel_instance_secret_generator" "init_code" {
  generator_type        = "init_code"
  length                = 8
  expiry                = "72h"
  include_lower_letters = true
  include_upper_letters = true
  include_digits        = true
  include_symbols       = false
}
