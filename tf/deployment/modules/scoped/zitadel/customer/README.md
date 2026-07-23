# Customer-facing ZITADEL

B2C ZITADEL Cloud instance used to hold **customer** end-user accounts for FUTO
products. Separate from the internal staff SSO instances under
`modules/shared/zitadel/`.

One Cloud instance per environment (same Cloud account as the internal FUTO
instance), with state and secrets scoped per `TF_VAR_env` (`dev`, `staging`,
`prod`).

Unlike `dev`/`prod`, the `staging` environment is **not** part of the
`modules/scoped` `run --all` sweep (that would also touch `discord/community`
and `monitoring/grafana`). The `terragrunt.yml` `Plan/Deploy Staging` steps run
this module on its own, with `ENVIRONMENT: staging` and
`OP_CONNECT_TOKEN_STAGING`.

## Bootstrap (manual, once per environment)

The ZITADEL provider needs an existing instance + a machine-user JWT profile
before Terraform can run. Do this in the ZITADEL Cloud console and 1Password:

1. Create a new instance for customer auth in the FUTO ZITADEL Cloud account.
   One per env — prod first, dev/staging later (or vice versa).
2. Custom domain — **prod only**: `auth.futo.cloud`. Add it on the instance in
   the ZITADEL Cloud console. The `auth.futo.cloud` CNAME → the prod instance
   URL is managed by this module (`dns.tf`, in the futo `futo.cloud` zone), so
   no manual DNS is needed. dev/staging have no custom domain — they use the
   generated `<name>.zitadel.cloud` instance URL directly.
3. In each instance, create a machine user with role `IAM_OWNER`, generate a
   JWT key, and download the profile JSON.
4. Apply `modules/shared/1password/futo-account` — the manual-secrets module
   seeds stub items in `yucca_tf_${env}_manual` with `REPLACE_ME` passwords
   for:
   - `CUSTOMER_ZITADEL_DOMAIN`
   - `CUSTOMER_ZITADEL_BASE_DOMAIN`
   - `CUSTOMER_ZITADEL_PROFILE_JSON`
   - `CUSTOMER_ZITADEL_SMTP_HOST`
   - `CUSTOMER_ZITADEL_SMTP_USER`
   - `CUSTOMER_ZITADEL_SMTP_PASSWORD`
   - `CUSTOMER_ZITADEL_SMTP_SENDER_ADDRESS`

   Replace each stub password in `yucca_tf_${env}_manual` with the real value
   (`CUSTOMER_ZITADEL_DOMAIN` = the public-facing auth URL — prod: the
   `auth.futo.cloud` vanity domain, dev/staging: the generated
   `<name>.zitadel.cloud` URL — consumed by app-side config, not this module;
   `CUSTOMER_ZITADEL_BASE_DOMAIN` = the generated `<name>.zitadel.cloud` instance
   host as a **bare hostname** (no `https://`, no trailing slash) in every env,
   which this module both connects through (provider + hosted login) and targets
   with the `auth.futo.cloud` CNAME, so the connection never depends on the
   mutable vanity domain. Stored bare to match the internal instance's
   `FUTO_ZITADEL_BASE_DOMAIN`. Profile JSON from step 3, SMTP
   credentials for the chosen provider, and sender address e.g.
   `no-reply@futo.cloud`).
   Re-apply `shared/1password/futo-account` so the copy-secrets module
   mirrors each value into the `yucca_tf_${env}` vault that this module
   reads from via `data "onepassword_item"` lookups at plan/apply time. No
   `.env` changes required for these, since the `onepassword` provider here
   uses `service_account_token = var.futo_op_service_account_token` which is
   already globally wired in `tf/deployment/.env`.
5. **Only when standing up a brand-new env** (e.g. `staging` — already done for
   `dev`/`prod`): the env-level plumbing that `tf/deployment/.env` and CI rely
   on must exist before this module can deploy:
   - In the **immich** 1Password account, create vaults `tf_${env}` and
     `tf_${env}_manual`, then add `tf_${env}` (and `tf_${env}_manual`) to the
     `scoped_vaults` of both modules in
     `modules/shared/1password/account/secrets.tf`. Applying `shared` seeds the
     env-scoped stubs (`MONITORING_GRAFANA_*`, `*_DISCORD_SERVER_ID`, …) — these
     are unused by this module but must exist so `op run` can resolve every
     `op://tf_${env}/...` ref in `.env`.
   - Manually add a `yucca_futo_1pass_superuser_service_account` item to
     `tf_${env}` holding a FUTO-account service-account token with access to
     `yucca_tf_${env}` — this is what `var.futo_op_service_account_token`
     resolves to.
   - Mint a 1Password Connect token scoped to the immich `tf` + `tf_${env}`
     vaults and add it as the `OP_CONNECT_TOKEN_${ENV^^}` GitHub Actions secret
     used by the `Plan/Deploy Staging` steps in `.github/workflows/terragrunt.yml`.

## Adding a new product OIDC client

Edit `projects.tf` and append to `local.projects_data`:

```hcl
{
  name         = "Immich Web"
  authMethod   = "NONE"              # "BASIC" for confidential clients
  appType      = "WEB"               # or "NATIVE", "USER_AGENT"
  grantTypes   = ["AUTHORIZATION_CODE"]
  redirectUris = ["https://app.immich.cloud/auth/callback"]
},
```

Apply the module. `client_id` and `client_secret` land in 1Password under
`CUSTOMER_ZITADEL_OAUTH_CLIENT_ID_<NAME>` / `..._CLIENT_SECRET_<NAME>` in the
`yucca_tf_$ENVIRONMENT` vault (FUTO 1Password account).

## Adding a machine user for a product backend

When a product backend needs to call the ZITADEL API (e.g. user lookup), add
a `machine_users.tf` following the pattern in
`modules/shared/zitadel/cloud/outline-role-sync.tf` — machine user + PAT +
`onepassword_item` + `zitadel_org_member` on `zitadel_org.customers` with the
least-privilege role that fits the use case (typically `ORG_USER_MANAGER`).

## Adding a social IDP (Google / Apple / GitHub)

1. Store the OAuth app `client_id` / `client_secret` in 1Password and add the
   `TF_VAR_*` lines to `.env`.
2. Add a new `idps.tf` with the relevant `zitadel_idp_*` resource.
3. Reference it from `zitadel_default_login_policy.default.idps` in
   `defaults.tf` (replace the current empty list).

## Branding

Colours live in `branding.tf` and track the FUTO palette from futo.tech
(`#3c9eea` primary, `#02070a` dark bg, `#cfeaff` dark font, `#f2b859` warn).

Logo / icon assets live under `assets/`:

- `assets/logo.svg` — the FUTO wordmark (blue gradient SVG lifted from the
  futo.tech header). Transparent background. Used for both light and dark
  themes via `logo_path` / `logo_dark_path` so it adapts to either.
- `assets/icon.svg` — square FUTO "O" symbol extracted from the wordmark
  (same blue gradient, centred in a 24×24 viewBox). Transparent by design.
  Used for both themes via `icon_path` / `icon_dark_path`.

To swap an asset, drop the new file into `assets/` keeping the same filename;
the `filemd5(...)` hash in `branding.tf` will detect the change and re-upload
on next apply. If you need distinct light/dark variants, add the new file
(e.g. `logo-dark.svg`), point `logo_dark_path` / `logo_dark_hash` at it, and
update this README.

`assets/*` is whitelisted via `include_in_copy` in `terragrunt.hcl` so the
directory makes it into the terragrunt working copy.

## Hosted login (v2) translations

The v2 TypeScript login UI ships its own bundled locale files. Three strings
in the default `en.json` reference "ZITADEL" by name; the ZITADEL terraform
provider does not currently expose the `SettingsService.SetHostedLoginTranslation`
endpoint that the v2 UI reads custom overrides from, so we push them with a
local-exec script.

- `translations/en.json` — only the keys being overridden (same nested shape
  as [zitadel/zitadel `apps/login/locales/en.json`](https://github.com/zitadel/zitadel/blob/main/apps/login/locales/en.json));
  the v2 UI deep-merges these on top of its bundled defaults.
- `scripts/set-hosted-login-translations.sh` — signs a client-assertion JWT
  from the 1Password-stored machine-user profile, exchanges it for an access
  token via `urn:ietf:params:oauth:grant-type:jwt-bearer`, and `PUT`s the JSON
  to `/v2/settings/hosted_login_translation`.
- `hosted_login_translations.tf` — a `null_resource` whose `triggers` hash the
  JSON + script + domain + locale, so the script re-runs only when something
  real changes. Runtime deps: `curl`, `jq`, `openssl`.
- `defaults.tf` sets `zitadel_instance_restrictions.allowed_languages = ["en"]`,
  so we don't have to maintain overrides for other locales.

To edit copy: change `translations/en.json`, re-apply the module. Plan output
only shows the trigger hash changing — use `git diff translations/en.json` to
see the actual text diff. Verify after apply with:

```sh
curl -H "Authorization: Bearer $TOKEN" \
  "https://$ZITADEL_DOMAIN/v2/settings/hosted_login_translation?locale=en&instance=true"
```

## Intentionally not present

- `idp.tf` — no social IDPs at launch.
- `actions.tf` — no custom login hooks needed (no GitHub/GitLab attribute
  mapping, no cross-product role-grant logic).
- `users.tf` / `permissions.tf` — customers self-register; no user
  provisioning or pre-defined user grants.
- `login_texts` / per-message text overrides — default ZITADEL copy is fine
  to start. Add `default_login_texts` / `default_*_message_text` resources if
  FUTO-signed copy is needed later.
