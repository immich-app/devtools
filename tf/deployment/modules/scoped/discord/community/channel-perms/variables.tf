variable "channel_ids" {
  description = "The ID of the channel to set permissions for."
  type        = set(string)
}

variable "role_ids" {
  description = "The ID of the roles to set permissions for."
  type        = set(string)
}

variable "everyone_id" {
  description = "The ID of the everyone role"
  type        = string
  default     = null
}

variable "public" {
  default = false
}

variable "allow" {
  description = "The permissions to allow for the role."
  type        = number
  default     = 0
}

variable "deny" {
  description = "The permissions to deny for the role."
  type        = number
  default     = 0
}
