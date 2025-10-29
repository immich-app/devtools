data "onepassword_vault" "manual_global" {
  name = var.global_vault
}

data "onepassword_vault" "manual_scoped" {
  for_each = var.scoped_vaults
  name     = each.key
}

data "onepassword_vault" "copy_global" {
  name = var.copy_global_vault
}

data "onepassword_vault" "copy_scoped" {
  for_each = var.scoped_vaults
  name     = each.value
}
