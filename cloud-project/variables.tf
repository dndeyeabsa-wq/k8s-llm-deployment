variable "project_name" {
  type = string
}

variable "environment" {
  type = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Doit être dev ou prod."
  }
}

variable "aws_region" {
  type = string
}

variable "dynamodb_hash_key" {
  type = string
}
