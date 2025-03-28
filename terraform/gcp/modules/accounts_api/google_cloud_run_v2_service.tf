resource "google_cloud_run_v2_service" "reearth_accounts_api" {
  project  = data.google_project.project.project_id
  name     = "reearth-accounts-api"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      name  = "reearth-accounts-api"
      image = var.image

      resources {
        cpu_idle          = true
        startup_cpu_boost = true

        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }

      ports {
        container_port = 8090
        name           = "http1"
      }

      env {
        name = "REEARTH_ACCOUNTS_DB"
        value_source {
          secret_key_ref {
            secret  = var.database_secret_id
            version = "latest"
          }
        }
      }

      env {
        name  = "REEARTH_ACCOUNTS_ORIGINS"
        value = join(",", var.origins)
      }

      env {
        name  = "CERBOS_HOST"
        value = var.cerbos_host
      }
    }

    scaling {
      max_instance_count = 20
      min_instance_count = 1
    }

    service_account = var.service_account_email
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
