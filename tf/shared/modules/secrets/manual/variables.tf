variable "secrets" {
  type = object({
    global = optional(list(string))
    scoped = optional(list(string))
  })
}

variable "global_vault" {
  type        = string
  description = "Name of the vault for storing global manual secrets"
  default     = "tf_manual"
}

variable "copy_global_vault" {
  type        = string
  description = "Name of the vault for copying global secrets to"
  default     = "tf"
}

variable "scoped_vaults" {
  type        = map(string)
  description = "Map of manual vault names to copy vault names for scoped secrets"
  default = {
    "tf_prod_manual" = "tf_prod"
    "tf_dev_manual"  = "tf_dev"
  }
}
