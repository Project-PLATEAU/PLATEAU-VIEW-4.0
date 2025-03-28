resource "google_cloud_run_v2_service" "reearth_flow_subscriber" {
  ingress  = "INGRESS_TRAFFIC_ALL"
  location = var.region
  name     = var.name
  project  = data.google_project.project.project_id

  template {
    containers {
      image = var.image

      ports {
        container_port = 8080
        name           = "http1"
      }

      resources {
        cpu_idle          = false
        startup_cpu_boost = true

        limits = var.resources.limits
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
        name  = "REEARTH_FLOW_SUBSCRIBER_ASSET_BASE_URL"
        value = "https://api.${var.domain}"
      }
      env {
        name = "REEARTH_FLOW_SUBSCRIBER_DB"
        value_source {
          secret_key_ref {
            secret  = var.database_secret_id
            version = "latest"
          }
        }
      }
      env {
        name  = "REEARTH_FLOW_SUBSCRIBER_EDGE_SUBSCRIPTION_ID"
        value = var.edge_pass_subscription_id
      }
      env {
        name  = "REEARTH_FLOW_SUBSCRIBER_LOG_SUBSCRIPTION_ID"
        value = var.log_subscription_id
      }
      env {
        name  = "REEARTH_FLOW_GCS_BUCKETNAME"
        value = var.gcs_bucket_name
      }
      env {
        name = "REEARTH_FLOW_SUBSCRIBER_REDIS_URL"
        value_source {
          secret_key_ref {
            secret  = var.redis_url_secret_id
            version = "latest"
          }
        }
      }
    }

    scaling {
      max_instance_count = var.scaling.max_instances
      min_instance_count = var.scaling.min_instances
    }

    service_account  = var.service_account_email
    session_affinity = true

    vpc_access {
      network_interfaces {
        network    = data.google_compute_network.default.name
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
