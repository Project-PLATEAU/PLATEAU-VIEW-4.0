variable "cerbos_host" {
  type        = string
  description = "Cerbos service host address for gRPC connection. Should be in format 'hostname:port' (e.g. 'cerbos.example.com:443'). For Cloud Run deployments, port 443 is required as it only supports HTTPS connections."

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}:[0-9]+$", var.cerbos_host))
    error_message = "The cerbos_host value must be in format 'hostname:port' (e.g. 'cerbos.example.com:443')."
  }
}

variable "database_secret_id" {
  type        = string
  description = "Secret ID of the database connection URL for MongoDB"
}

variable "domain" {
  type        = string
  description = "Custom domain to be used for Re:Earth."
}

variable "image" {
  type        = string
  description = "Image of the Re:Earth Accounts API."
}

variable "origins" {
  type        = list(string)
  description = "CORS origins allowed."

  validation {
    condition     = alltrue([for origin in var.origins : can(regex("^(http|https)://", origin))])
    error_message = "CORS origins must start with http:// or https://."
  }
}

variable "project" {
  description = "ID of the GCP project."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project))
    error_message = "Project ID must start with a lowercase letter, and can include lowercase letters, numbers, or hyphens. It must be between 6 and 30 characters long."
  }
}

variable "region" {
  type        = string
  default     = "asia-northeast1"
  description = "Region to host the resources."
}

variable "service_account_email" {
  type        = string
  description = "Email of the service account to be used for Re:Earth."

  validation {
    condition     = can(regex("^[a-z0-9-_]+@[a-z0-9-_.]+$", var.service_account_email))
    error_message = "Service account email must be in the format of <name>@<domain>."
  }
}
