# FUTO Cloudflare account

Manages resources in the **separate FUTO Cloudflare account** (currently the
`futo.cloud`, `futo.network` and `as402421.net` zones). This mirrors the
immich-account modules under `modules/shared/cloudflare/` but reads its
credentials from — and writes any generated secrets back to — the **FUTO
1Password account** via `var.futo_op_service_account_token` (already wired
globally in `tf/deployment/.env`), the same way `netbird/account` and
`zitadel/cloud` do.

> **Cloudflare provider v5.** These two modules pin cloudflare provider v5 (the
> rest of the repo is still on v4 — provider versions are per-module). v5 is
> required for **account-owned** API tokens (`cloudflare_account_token`); v4's
> `cloudflare_api_token` is user-owned and needs user-level auth, which a
> separate account managed by an account-scoped token doesn't have (error 9109).

## Layout

- `cloudflare/futo-api-keys` — uses the root FUTO Cloudflare token to mint a
  scoped, account-owned `terraform_futo_cloudflare_account` token, exported via
  remote state (`prod_cloudflare_futo_api_keys`).
- `cloudflare/futo-account` (this module) — consumes that scoped token and
  manages the zones (`prod_cloudflare_futo_account`).

## Bootstrap (manual, once)

1. In the FUTO Cloudflare dashboard, create a root **account-owned** API token
   (Account → API Tokens) with **Account API Tokens Write** and note the
   **account ID**.
2. Apply `modules/shared/1password/futo-account` — `shared-manual-secrets` seeds
   stub items in `shared_tf_manual` with `REPLACE_ME` passwords for:
   - `CLOUDFLARE_ACCOUNT_ID`
   - `CLOUDFLARE_API_TOKEN`

   Replace each stub password in `shared_tf_manual` with the real value, then
   re-apply `1password/futo-account` so the copy module mirrors them into the
   `shared_tf` vault this module reads from. No `.env` changes are required.
3. Apply `cloudflare/futo-api-keys`, then `cloudflare/futo-account`.

## Zones

- `futo.cloud` — pre-existing in the account, brought in via an `import` block
  (zone ID `474fbfd96bf49879054a493f126c4071`).
- `futo.network`, `as402421.net` — created fresh by this module (no `import`
  block).

## Adding a zone

Add a `cloudflare_zone` resource in `zones.tf` and an entry to `local.zones` —
the `cloudflare_zone_setting` and `cloudflare_tiered_cache` resources fan out
over that map automatically. If the zone already exists in the account, add an
`import` block with its zone ID; if it's brand new, leave the import block off
and Terraform will create it. As new resource types are added, append the
matching permission group names to `local.token_permission_names` in
`cloudflare/futo-api-keys/api-keys.tf`.
