variable "secrets" {
  type = object({
    global = optional(list(object({
      name   = string
      length = optional(number)
      type   = optional(string, "alphanumeric")
    })))
    scoped = optional(list(object({
      name   = string
      length = optional(number)
      type   = optional(string, "alphanumeric")
    })))
  })
}

variable "global_vault" {
  type        = string
  description = "Name of the vault for storing global secrets"
  default     = "tf"
}

variable "scoped_vaults" {
  type        = set(string)
  description = "Names of the vaults for storing scoped secrets"
  default     = ["tf_prod", "tf_dev"]
}

variable "default_secret_length" {
  type        = number
  description = "The default length for generated secrets if not specified per secret."
  default     = 40
}
