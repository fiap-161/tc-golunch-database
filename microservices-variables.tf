# Additional variables for microservices databases

# Payment Service (DynamoDB)
# Nota: DynamoDB não requer username/password, essas variáveis não são mais usadas
# Mantidas para referência caso necessário no futuro
variable "mongodb_username" {
  description = "Payment Service - não utilizado (DynamoDB não requer autenticação)"
  type        = string
  default     = ""
}

variable "mongodb_password" {
  description = "Payment Service - não utilizado (DynamoDB não requer autenticação)"
  type        = string
  sensitive   = true
  default     = ""
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