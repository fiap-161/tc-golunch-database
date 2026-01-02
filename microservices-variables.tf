# Additional variables for microservices databases

# Payment Service (MongoDB/DocumentDB)
variable "mongodb_username" {
  description = "Payment Service DocumentDB username"
  type        = string
  default     = "golunch_payment"
}

variable "mongodb_password" {
  description = "Payment Service DocumentDB password"
  type        = string
  sensitive   = true
  default     = "golunch_payment123"
}

# Operation Service Database
variable "operation_db_username" {
  description = "Operation Service database username"
  type        = string
  default     = "golunch_operation"
}

variable "operation_db_password" {
  description = "Operation Service database password"
  type        = string
  sensitive   = true
  default     = "golunch_operation123"
}

# Core Service Database (rename existing variables for consistency)
variable "core_db_username" {
  description = "Core Service database username"
  type        = string
  default     = "golunch_core"
}

variable "core_db_password" {
  description = "Core Service database password"
  type        = string
  sensitive   = true
  default     = "golunch_core123"
}