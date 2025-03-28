resource "google_cloud_run_v2_service" "reearth_flow_websocket" {
  name     = var.name
  location = var.region
  project  = data.google_project.project.project_id
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      name  = var.name
      image = var.image

      resources {
        cpu_idle          = false # Keep CPU active for reearth_flow_websocket connections
        startup_cpu_boost = true

        limits = var.resources.limits
      }

      ports {
        container_port = 8080
        name           = "http1"
      }

      env {
        name  = "REEARTH_FLOW_APP_ENV"
        value = "production"
      }

      env {
        name  = "REEARTH_FLOW_GCS_BUCKET_NAME"
        value = var.gcs_bucket_name
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
        name  = "REEARTH_FLOW_THRIFT_AUTH_URL"
        value = var.thrift_auth_url
      }

      env {
        name  = "REEARTH_FLOW_WS_PORT"
        value = "8080"
      }
    }

    scaling {
      min_instance_count = var.scaling.min_instances
      max_instance_count = var.scaling.max_instances
    }

    session_affinity = true
    service_account  = var.service_account_email

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
