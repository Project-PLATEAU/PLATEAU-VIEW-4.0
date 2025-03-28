resource "google_cloud_run_v2_service" "reearth_flow_api" {
  ingress  = "INGRESS_TRAFFIC_ALL"
  location = var.region
  name     = "reearth-flow-api"
  project  = data.google_project.project.project_id

  template {
    containers {
      image = var.image
      name  = "reearth-flow-api"

      ports {
        container_port = 8080
        name           = "http1"
      }

      resources {
        cpu_idle          = false
        startup_cpu_boost = true
        limits            = var.resources.limits
      }

      env {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = data.google_project.project.project_id
      }
      env {
        name  = "GOOGLE_CLOUD_REGION"
        value = var.region
      }
      env {
        name  = "REEARTH_ACCOUNTS_API_HOST"
        value = "https://${var.accounts_api_domain}"
      }
      env {
        name  = "REEARTH_FLOW_ASSETBASEURL"
        value = "https://api.${var.domain}"
      }
      env {
        name  = "REEARTH_FLOW_AUTH0_AUDIENCE"
        value = var.auth0_audience
      }
      env {
        name  = "REEARTH_FLOW_AUTH0_CLIENTID"
        value = var.auth0_client_id
      }
      env {
        name = "REEARTH_FLOW_AUTH0_CLIENTSECRET"
        value_source {
          secret_key_ref {
            secret  = var.auth0_client_secret_secret_id
            version = "latest"
          }
        }
      }
      env {
        name  = "REEARTH_FLOW_AUTH0_DOMAIN"
        value = "https://${var.auth0_domain}/"
      }
      env {
        name  = "REEARTH_FLOW_AUTHSRV_DISABLED"
        value = "true"
      }
      env {
        name = "REEARTH_FLOW_DB"
        value_source {
          secret_key_ref {
            secret  = var.database_secret_id
            version = "latest"
          }
        }
      }
      env {
        name  = "REEARTH_FLOW_DB_ACCOUNT"
        value = "reearth-account"
      }
      env {
        name  = "REEARTH_FLOW_GCS_BUCKETNAME"
        value = var.gcs_bucket_name
      }
      env {
        name  = "REEARTH_FLOW_GCS_PUBLICATIONCACHECONTROL"
        value = "no-store"
      }
      env {
        name  = "REEARTH_FLOW_HOST"
        value = "https://api.${var.domain}"
      }
      env {
        name  = "REEARTH_FLOW_HOST_WEB"
        value = "https://${var.domain}"
      }
      env {
        name  = "REEARTH_FLOW_ORIGINS"
        value = join(",", var.origins)
      }
      env {
        name = "REEARTH_FLOW_REDIS_URL"
        value_source {
          secret_key_ref {
            secret  = var.redis_url_secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "REEARTH_FLOW_SIGNUPSECRET"
        value_source {
          secret_key_ref {
            secret  = var.signup_secret_secret_id
            version = "latest"
          }
        }
      }
      env {
        name  = "REEARTH_FLOW_WEBSOCKET_THRIFT_SERVER_URL"
        value = var.websocket_thrift_server_url
      }
      env {
        name  = "REEARTH_FLOW_WORKER_BATCH_ALLOWED_LOCATIONS"
        value = join(",", var.worker_allowed_locations)
      }
      env {
        name  = "REEARTH_FLOW_WORKER_BATCH_SA_EMAIL"
        value = var.worker_batch_sa_email
      }
      env {
        name  = "REEARTH_FLOW_WORKER_BINARY_PATH"
        value = var.worker_binary_path
      }
      env {
        name  = "REEARTH_FLOW_WORKER_BOOT_DISK_SIZE_GB"
        value = var.worker_boot_disk_size_gb
      }
      env {
        name  = "REEARTH_FLOW_WORKER_BOOT_DISK_TYPE"
        value = var.worker_boot_disk_type
      }
      env {
        name  = "REEARTH_FLOW_WORKER_COMPUTE_CPU_MILLI"
        value = var.worker_compute_cpu_milli
      }
      env {
        name  = "REEARTH_FLOW_WORKER_COMPUTE_MEMORY_MIB"
        value = var.worker_compute_memory_mibytes
      }
      env {
        name  = "REEARTH_FLOW_WORKER_IMAGE_URL"
        value = var.worker_image_url
      }
      env {
        name  = "REEARTH_FLOW_WORKER_MACHINE_TYPE"
        value = var.worker_machine_type
      }
      env {
        name  = "REEARTH_FLOW_WORKER_MAX_CONCURRENCY"
        value = var.worker_max_concurrency
      }
      env {
        name  = "REEARTH_FLOW_WORKER_PUBSUB_EDGE_PASS_THROUGH_EVENT_TOPIC"
        value = var.worker_pubsub_edge_pass_through_event_topic
      }
      env {
        name  = "REEARTH_FLOW_WORKER_PUBSUB_JOB_COMPLETE_TOPIC"
        value = var.worker_pubsub_job_complete_topic
      }
      env {
        name  = "REEARTH_FLOW_WORKER_PUBSUB_LOG_STREAM_TOPIC"
        value = var.worker_pubsub_log_stream_topic
      }
      env {
        name  = "REEARTH_FLOW_WORKER_TASK_COUNT"
        value = var.worker_task_count
      }
    }

    scaling {
      max_instance_count = 20
      min_instance_count = 1
    }

    service_account  = var.service_account_email
    session_affinity = true

    vpc_access {
      network_interfaces {
        network    = "default"
        subnetwork = "default"
      }
    }
  }

  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }

  lifecycle {
    ignore_changes = [
      client,
      client_version,
      template[0].containers[0].image,
      template[0].revision,
      traffic[0].revision,
      traffic[0].type,
    ]
  }
}
