# FUTO bunny.net DNS

Reverse DNS for the FUTO `69.48.224.0/22` range, on **bunny.net** (they support
`PTR` records and `arpa` zones). Reads its API key from the FUTO **`shared_tf`**
1Password vault (`BUNNY_API_KEY`, seeded via `1password/futo-account`) using the
futo service-account token, the same way the other futo modules do.

## Zones

- `{224,225,226,227}.48.69.in-addr.arpa` — the four reverse zones + PTR records
  for all 1024 IPs.
- `rdns.as402421.net` — the forward FCrDNS names (`ip-69-48-<octet>-<host>`).
  `as402421.net` itself stays in Cloudflare; the `rdns` subdomain is delegated
  here via `NS` records in `cloudflare/futo-account` (`kiki.bunny.net` /
  `coco.bunny.net`).

By default each IP gets a matching PTR + A pair (FCrDNS). To point a single IP's
PTR elsewhere, add it to `reverse_ptr_overrides` in `dns-reverse.tf` — that IP
then gets no forward A record here.

## Delegation not managed here

The `in-addr.arpa` zones need their **upstream** delegation (the RIR / provider
that assigned `69.48.224.0/22`) repointed to `kiki.bunny.net` / `coco.bunny.net`.
That's set at the RIR/upstream, not in Terraform. The `rdns.as402421.net`
delegation *is* managed here (the Cloudflare `NS` records).
