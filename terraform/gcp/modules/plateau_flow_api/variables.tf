variable "accounts_api_domain" {
  type        = string
  description = "Domain of Accounts API."
}

variable "auth0_audience" {
  type        = string
  description = "Domain of the Auth0 Audience"
}

variable "auth0_domain" {
  type        = string
  description = "Domain of the Auth0 tenant."
}

variable "auth0_client_id" {
  type        = string
  description = "Client ID of the Auth0 M@M client."
}

variable "auth0_client_secret_secret_id" {
  type        = string
  description = "Auth0 client secret for authentication"
}

variable "domain" {
  type        = string
  description = "Custom domain to be used for PLATEAU."
}

variable "database_secret_id" {
  type        = string
  description = "Secret ID of the database connection URL for MongoDB"
}

variable "gcs_bucket_name" {
  type        = string
  description = "Name of the GCS bucket."
}

variable "image" {
  type        = string
  description = "Image of the PLATEAU Flow API."
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

variable "redis_url_secret_id" {
  type    = string
  default = "Secret ID of the Redis URL"
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

variable "region" {
  type        = string
  default     = "asia-northeast1"
  description = "Region to host the resources."
}

variable "service_account_email" {
  type        = string
  description = "Email of the service account to be used for PLATEAU Flow"

  validation {
    condition     = can(regex("^[a-z0-9-_]+@[a-z0-9-_.]+$", var.service_account_email))
    error_message = "Service account email must be in the format of <name>@<domain>."
  }
}

variable "signup_secret_secret_id" {
  type        = string
  description = "Secret ID used for PLATEAU verify signup webhook."
}

variable "websocket_thrift_server_url" {
  type        = string
  description = "URL of the Websocket Thrift Server service."
}

variable "worker_allowed_locations" {
  type        = list(string)
  description = "PLATEAU Flow Worker Batch Allowed locations."

  validation {
    condition     = alltrue([for location in var.worker_allowed_locations : can(regex("^(regions|zones)/[a-z0-9-]+$", location))])
    error_message = "Allowed locations must be in the format of regions/<region> or zones/<zone>."
  }
}

variable "worker_batch_sa_email" {
  type        = string
  description = "Email of the PLATEAU Flow Worker Batch Service Account."
}

variable "worker_binary_path" {
  type        = string
  description = "Path to the PLATEAU Flow Worker binary."
}

variable "worker_boot_disk_size_gb" {
  type        = string
  description = "PLATEAU Flow Worker Disk Size in GB"
  default     = "50"
}

variable "worker_boot_disk_type" {
  type        = string
  description = "PLATEAU Flow Worker Disk Type"
  default     = "pd-balanced"
}


variable "worker_compute_cpu_milli" {
  type        = string
  description = "PLATEAU Flow Worker Compute CPU Milli"
  default     = "2000"
}

variable "worker_compute_memory_mibytes" {
  type        = string
  description = "PLATEAU Flow Worker Compute Memory in Mibytes"
  default     = "2000"
}

variable "worker_image_url" {
  type        = string
  description = "Image of the PLATEAU Flow Worker"
}

variable "worker_machine_type" {
  type        = string
  description = "PLATEAU Flow Worker Machine Type"
  default     = "e2-standard-4"
}

variable "worker_max_concurrency" {
  type        = string
  description = "PLATEAU Flow Worker Max Concurrency"
  default     = "4"
}

variable "worker_pubsub_edge_pass_through_event_topic" {
  type        = string
  description = "PLATEAU Flow Worker PubSub Edge Pass Through Event Topic"
  default     = "flow-edge-pass-through"
}

variable "worker_pubsub_job_complete_topic" {
  type        = string
  description = "PLATEAU Flow Worker PubSub Job Complete Topic"
  default     = "flow-job-complete"
}

variable "worker_pubsub_log_stream_topic" {
  type        = string
  description = "PLATEAU Flow Worker PubSub Log Stream Topic"
  default     = "flow-log-stream"
}

variable "worker_task_count" {
  type        = string
  description = "PLATEAU Flow Worker Task Count"
  default     = "1"
}
