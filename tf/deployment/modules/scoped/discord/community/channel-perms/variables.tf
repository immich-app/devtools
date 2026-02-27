variable "channels" {
  description = "Map of channel name to channel ID to set permissions for."
  type        = map(string)
}

variable "roles" {
  description = "Map of role name to role ID to set permissions for."
  type        = map(string)
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
