variable "secrets" {
  type = object({
    global = optional(list(object({
      name   = string
      length = optional(number)
    })))
    dev = optional(list(object({
      name   = string
      length = optional(number)
    })))
    prod = optional(list(object({
      name   = string
      length = optional(number)
    })))
  })
}

variable "default_secret_length" {
  type        = number
  description = "The default length for generated secrets if not specified per secret."
  default     = 40
}
