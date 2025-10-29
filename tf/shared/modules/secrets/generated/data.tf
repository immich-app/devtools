data "onepassword_vault" "global" {
  name = var.global_vault
}

data "onepassword_vault" "scoped" {
  for_each = var.scoped_vaults
  name     = each.value
}
