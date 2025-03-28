resource "google_cloud_run_v2_service" "cerbos" {
  project  = data.google_project.project.project_id
  location = var.region
  name     = "cerbos"

  template {
    containers {
      image = var.image
      args = [
        "server",
        "--config",
        "/policies/.cerbos.yaml",
      ]

      resources {
        cpu_idle          = true
        startup_cpu_boost = true

        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }

      env {
        name  = "MOUNTPATH"
        value = "/policies"
      }

      volume_mounts {
        name       = data.google_storage_bucket.policy_bucket.name
        mount_path = "/policies"
      }
    }

    volumes {
      name = data.google_storage_bucket.policy_bucket.name

      gcs {
        bucket    = data.google_storage_bucket.policy_bucket.name
        read_only = false
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
      template[0].revision,
      traffic[0].revision,
      traffic[0].type,
    ]
  }
}
