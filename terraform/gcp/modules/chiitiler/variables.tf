variable "image" {
  type        = string
  description = "Image of chiitiler."
}

variable "prefix" {
  type        = string
  description = "Prefix of the resources."
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

variable "resources" {
  description = "Resorce configuration for the Cloud Run service."
  default = {
    limits = {
      cpu    = "1000m"
      memory = "256Mi"
    }
  }

  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
  })
}

variable "service_account_email" {
  type        = string
  description = "Email of the service account to be used for Re:Earth Flow"

  validation {
    condition     = can(regex("^[a-z0-9-_]+@[a-z0-9-_.]+$", var.service_account_email))
    error_message = "Service account email must be in the format of <name>@<domain>."
  }
}
