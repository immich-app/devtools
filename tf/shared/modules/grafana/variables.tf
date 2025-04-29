variable "env" {}

variable "folder_name" {
  description = "Name of the folder to create in Grafana"
  type        = string
}

variable "folder_exists" {
  description = "Whether the folder already exists in Grafana"
  type        = bool
  default     = false
}

variable "dashboards_path" {
  description = "Path to the dashboards directory"
  type        = string
}
