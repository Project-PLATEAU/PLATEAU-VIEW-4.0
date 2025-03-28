resource "google_cloud_run_v2_service" "reearth_flow_web" {
  project  = data.google_project.project.project_id
  name     = "reearth-flow-web"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      name  = "reearth-flow-web"
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
        name  = "FLOW_API"
        value = "https://api.${var.domain}"
      }

      env {
        name  = "FLOW_AUTH0_AUDIENCE"
        value = var.auth0_audience
      }

      env {
        name  = "FLOW_AUTH0_CLIENT_ID"
        value = var.auth0_client_id
      }

      env {
        name  = "FLOW_AUTH0_DOMAIN"
        value = "https://${var.auth0_domain}"
      }

      env {
        name  = "FLOW_BRAND_NAME"
        value = var.brand_name
      }

      env {
        name  = "FLOW_BRAND_FAVICON_URL"
        value = var.brand_favicon_url
      }

      env {
        name  = "FLOW_BRAND_LOGO_URL"
        value = var.brand_logo_url
      }

      env {
        name  = "FLOW_DEV_MODE"
        value = var.dev_mode
      }

      env {
        name  = "FLOW_DOCUMENTATION_URL"
        value = var.documentation_url
      }

      env {
        name  = "FLOW_TOS_URL"
        value = var.tos_url
      }

      env {
        name  = "FLOW_VERSION"
        value = var.flow_version
      }

      env {
        name  = "FLOW_WEBSOCKET"
        value = var.websocket_url
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
