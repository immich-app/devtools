variable "secrets" {
  type = object({
    global = optional(list(object({
      name   = string
      length = optional(number)
      type   = optional(string, "alphanumeric")
    })))
    dev = optional(list(object({
      name   = string
      length = optional(number)
      type   = optional(string, "alphanumeric")
    })))
    prod = optional(list(object({
      name   = string
      length = optional(number)
      type   = optional(string, "alphanumeric")
    })))
  })
}

variable "default_secret_length" {
  type        = number
  description = "The default length for generated secrets if not specified per secret."
  default     = 40
}
