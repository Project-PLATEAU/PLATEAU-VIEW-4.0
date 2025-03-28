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
  description = "Image of the Re:Earth Flow Subscriber"
}

variable "edge_pass_subscription_id" {
  type        = string
  description = "ID of the Pub/Sub Subscription for logs"
}

variable "log_subscription_id" {
  type        = string
  description = "ID of the Pub/Sub Subscription for logs"
}

variable "name" {
  description = "Name of the Cloud Run service"
  type        = string
  default     = "reearth-flow-subscriber"
}

variable "gcs_bucket_name" {
  type        = string
  description = "Name of the GCS bucket."
}

variable "port" {
  type        = number
  description = "Port for the Subscriber server"
  default     = 8080
}

variable "project" {
  description = "ID of the GCP project."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project))
    error_message = "Project ID must start with a lowercase letter, and can include lowercase letters, numbers, or hyphens. It must be between 6 and 30 characters long."
  }
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

variable "redis_url_secret_id" {
  type    = string
  default = "Secret ID of the Redis URL"
}

variable "region" {
  type        = string
  default     = "asia-northeast1"
  description = "Region to host the resources."
}

variable "service_account_email" {
  type        = string
  description = "Email of the service account to be used for Re:Earth Flow Subscriber"

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
