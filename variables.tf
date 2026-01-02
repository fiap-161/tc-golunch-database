variable "db_username" {
  description = "Database master username"
  type        = string
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "core_db_username" {
  description = "Core Service database username"
  type        = string
  default     = "golunch_core_user"
}

variable "core_db_password" {
  description = "Core Service database password"
  type        = string
  sensitive   = true
}
