variable "image" {
  type        = string
  description = "Image of cerbos."
}

variable "project" {
  description = "ID of the GCP project."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project))
    error_message = "Project ID must start with a lowercase letter, and can include lowercase letters, numbers, or hyphens. It must be between 6 and 30 characters long."
  }
}

variable "policy_bucket" {
  type        = string
  description = "Name of the bucket to store Cerbos policies."
}

variable "region" {
  type        = string
  default     = "asia-northeast1"
  description = "Region to host the resources."

  validation {
    condition     = contains(["asia-northeast1", "southamerica-east1", "us-central1"], var.region)
    error_message = "Environment variable must be either 'asia-northeast1', 'southamerica-east1', or 'us-central1'."
  }
}

variable "service_account_email" {
  type        = string
  description = "Email of the service account to be used for Re:Earth."

  validation {
    condition     = can(regex("^[a-z0-9-_]+@[a-z0-9-_.]+$", var.service_account_email))
    error_message = "Service account email must be in the format of <name>@<domain>."
  }
}
