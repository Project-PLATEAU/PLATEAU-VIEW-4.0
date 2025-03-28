resource "google_cloud_run_v2_service" "chiitiler" {
  project  = data.google_project.project.project_id
  name     = "chiitiler"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      name  = "chiitiler"
      image = var.image

      resources {
        cpu_idle          = true
        startup_cpu_boost = true

        limits = {
          cpu    = var.resources.limits.cpu
          memory = var.resources.limits.memory
        }
      }

      ports {
        container_port = 3000
      }

      env {
        name  = "CHIITILER_DEBUG"
        value = "true"
      }
    }

    scaling {
      max_instance_count = 20
      min_instance_count = 0
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
