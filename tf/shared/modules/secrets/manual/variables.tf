variable "secrets" {
  type = object({
    global = optional(list(string))
    dev    = optional(list(string))
    prod   = optional(list(string))
  })
}
