variable "auth0_audience" {
  type        = string
  description = "Domain of the Auth0 Audience"
}

variable "auth0_client_id" {
  type        = string
  description = "Client ID of the Auth0 SPA client."
}

variable "auth0_domain" {
  type        = string
  description = "Domain of the Auth0 tenant."
}

variable "brand_name" {
  type        = string
  description = "Brand Name for Re:Earth Flow UI."
}

variable "brand_favicon_url" {
  type        = string
  description = "Favicon URL to be used for Re:Earth Flow UI."
  default     = ""
}

variable "brand_logo_url" {
  type        = string
  description = "Logo URL to be used for Re:Earth Flow UI."
  default     = ""
}

variable "dev_mode" {
  type        = bool
  description = "Dev Mode to be used for Re:Earth Flow UI."
}

variable "documentation_url" {
  type        = string
  description = "Documentation URL to be used for Re:Earth Flow UI."
}

variable "domain" {
  type        = string
  description = "Custom domain to be used for Re:Earth Flow UI."
}

variable "flow_version" {
  type        = string
  description = "Version to be used for Re:Earth Flow UI."
}

variable "gh_repo_url" {
  type        = string
  description = "Github Repo URL Re:Earth Flow."
}

variable "image" {
  type        = string
  description = "Image of the Re:Earth Flow UI."
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

variable "tos_url" {
  type        = string
  description = "Terms of Service URL to be used for Re:Earth Flow UI."
}

variable "websocket_url" {
  type        = string
  description = "Websocket URL to be used for Re:Earth Flow UI."
}
