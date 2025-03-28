variable "gcs_bucket_name" {
  type        = string
  description = "Name of the GCS bucket."
}

variable "host" {
  type        = string
  description = "Host to bind the WebSocket server to"
  default     = "0.0.0.0" # Use 0.0.0.0 for Cloud Run
}

variable "image" {
  type        = string
  description = "Image of the Re:Earth Flow Websocket"
}

variable "name" {
  description = "Name of the Cloud Run service"
  type        = string
  default     = "reearth-flow-websocket"
}

variable "origins" {
  type        = list(string)
  description = "CORS origins allowed."

  validation {
    condition     = alltrue([for origin in var.origins : can(regex("^(http|https)://", origin))])
    error_message = "CORS origins must start with http:// or https://."
  }
}

variable "port" {
  type        = number
  description = "Port for the WebSocket server"
  default     = 8080 # Cloud Run requirement
}

variable "project" {
  type        = string
  description = "The GCP project ID"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project))
    error_message = "Project ID must start with a lowercase letter, and can include lowercase letters, numbers, or hyphens. It must be between 6 and 30 characters long."
  }
}

variable "redis_url_secret_id" {
  type    = string
  default = "Secret ID of the Redis URL"
}

variable "region" {
  type        = string
  description = "The region for Cloud Run"
  default     = "asia-northeast1"
}

variable "resources" {
  description = "Resource limits for the service"
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits = {
      cpu    = "2000m"
      memory = "4Gi"
    }
  }
}

variable "service_account_email" {
  type        = string
  description = "Email of the service account to be used for Re:Earth Flow"

  validation {
    condition     = can(regex("^[a-z0-9-_]+@[a-z0-9-_.]+$", var.service_account_email))
    error_message = "Service account email must be in the format of <name>@<domain>."
  }
}

variable "scaling" {
  description = "Scaling configuration for the service"
  type = object({
    min_instances = number
    max_instances = number
  })
  default = {
    min_instances = 3
    max_instances = 20
  }
}

variable "thrift_auth_url" {
  type        = string
  description = "URL of the Thrift Auth service"
}
