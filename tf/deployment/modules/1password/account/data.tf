data "onepassword_vault" "manual" {
  name = "tf_manual"
}

data "onepassword_vault" "manual_dev" {
  name = "tf_dev_manual"
}

data "onepassword_vault" "manual_prod" {
  name = "tf_prod_manual"
}

data "onepassword_vault" "tf" {
  name = "tf"
}

data "onepassword_vault" "tf_dev" {
  name = "tf_dev"
}

data "onepassword_vault" "tf_prod" {
  name = "tf_prod"
}

data "onepassword_vault" "kubernetes" {
  name = "Kubernetes"
}
