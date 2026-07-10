// Expose resolved secrets so another module can mirror them to a second
// 1Password account (see 1password/account/immich-vault-futo-copy.tf). Metadata
// and values are split so consumers can drive `for_each` off the non-sensitive
// keys and look the value up by key inside the resource — a sensitive value
// can't be used in `for_each`.
output "secret_meta" {
  description = "Non-sensitive metadata (title + copy-vault name) for each manual secret, keyed by <vault_name>_<title>."
  value = {
    for secret in local.secrets :
    "${secret.vault.name}_${secret.name}" => {
      title      = secret.name
      vault_name = secret.vault.name
    }
  }
}

output "secret_values" {
  description = "Resolved manual secret values keyed by <vault_name>_<title>."
  sensitive   = true
  value = {
    for secret in local.secrets :
    "${secret.vault.name}_${secret.name}" => onepassword_item.copy["${secret.vault.name}_${secret.name}"].password
  }
}
