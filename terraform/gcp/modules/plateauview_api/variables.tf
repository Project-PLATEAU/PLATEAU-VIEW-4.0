variable "ckan_token" {
  type        = string
  description = "FMEトークン"
  sensitive   = true
}

variable "chiitiler_url" {
  type        = string
  default     = ""
  description = "chiitierのURL"
}

variable "chiitiler_bucket" {
  type        = string
  default     = ""
  description = "chiitierのキャッシュ用バケット名"
}

variable "domain" {
  type        = string
  description = "PLATEAU VIEWを提供するドメイン名"
}

variable "fme_token" {
  type        = string
  description = "FMEトークン"
  sensitive   = true
}

variable "gcp_project_id" {
  type        = string
  description = "GCPプロジェクトのID"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.gcp_project_id))
    error_message = "GCPプロジェクトIDは、小文字で始まり、小文字、数字、またはハイフンを含む必要があります。また、6文字以上30文字以下の長さである必要があります。"
  }
}

variable "gcp_region" {
  type        = string
  default     = "asia-northeast1"
  description = "GCPで使用するリージョン"
}

variable "plateauview" {
  type = object({
    ckan_org                  = string
    ckan_base_url             = string
    cms_plateau_project       = string
    cms_system_project        = string
    datacatalog_cache_size    = string
    datacatalog_cache_percent = number
    fme_baseurl               = string
    fme_skip_quality_check    = string
    fme_url_v3                = string
    option_to                 = string
    option_from               = string
  })
}

variable "prefix" {
  type        = string
  description = "作成されるリソース名のプレフィックス"
}

variable "sendgrid_api_key" {
  type        = string
  description = "SendGridのAPIキー"
  sensitive   = true
}

variable "service_account_email" {
  type        = string
  description = "Email of the service account to be used for Re:Earth."

  validation {
    condition     = can(regex("^[a-z0-9-_]+@[a-z0-9-_.]+$", var.service_account_email))
    error_message = "Service account email must be in the format of <name>@<domain>."
  }
}
