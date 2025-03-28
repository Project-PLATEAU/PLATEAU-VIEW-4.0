resource "google_cloud_run_v2_service" "plateauview_api" {
  project  = data.google_project.project.project_id
  name     = "plateauview-api"
  ingress  = "INGRESS_TRAFFIC_ALL"
  location = var.gcp_region

  template {
    execution_environment = "EXECUTION_ENVIRONMENT_GEN2"
    service_account       = var.service_account_email
    timeout               = "3600s"

    containers {
      image = "eukarya/plateauview-api:latest"
      resources {
        limits = {
          cpu    = "1000m"
          memory = "1Gi"
        }
      }

      ports {
        container_port = 8080
        name           = "http1"
      }

      dynamic "env" {
        for_each = { for i in local.plateauview_secrets : i => i }
        content {
          name = env.value
          value_source {
            secret_key_ref {
              secret  = google_secret_manager_secret.plateauview[env.value].secret_id
              version = "latest"
            }
          }
        }
      }

      env {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = var.gcp_project_id
      }

      env {
        name  = "GOOGLE_CLOUD_REGION"
        value = var.gcp_region
      }

      dynamic "env" {
        for_each = var.chiitiler_url != "" ? [""] : []
        content {
          name  = "REEARTH_PLATEAUVIEW_CHIITILER_URL"
          value = var.chiitiler_url
        }
      }

      dynamic "env" {
        for_each = var.chiitiler_bucket != "" ? [""] : []
        content {
          name  = "REEARTH_PLATEAUVIEW_CHIITILER_BUCKET"
          value = var.chiitiler_bucket
        }
      }

      env {
        name  = "REEARTH_PLATEAUVIEW_CMS_BASEURL"
        value = "https://${local.api_cms_domain}"
      }

      env {
        name  = "REEARTH_PLATEAUVIEW_CKAN_BASEURL"
        value = var.plateauview.ckan_base_url
      }

      env {
        name  = "REEARTH_PLATEAUVIEW_CKAN_ORG"
        value = var.plateauview.ckan_org
      }

      env {
        name  = "REEARTH_PLATEAUVIEW_CMS_PLATEAUPROJECT"
        value = var.plateauview.cms_plateau_project
      }

      env {
        name  = "REEARTH_PLATEAUVIEW_CMS_SYSTEMPROJECT"
        value = var.plateauview.cms_system_project
      }

      env {
        name  = "REEARTH_PLATEAUVIEW_DATACATALOG_CACHEGCPARCENT"
        value = var.plateauview.datacatalog_cache_percent
      }

      env {
        name  = "REEARTH_PLATEAUVIEW_DATACATALOG_CACHESIZE"
        value = var.plateauview.datacatalog_cache_size
      }

      env {
        name  = "REEARTH_PLATEAUVIEW_FME_BASEURL"
        value = var.plateauview.fme_baseurl
      }

      env {
        name  = "REEARTH_PLATEAUVIEW_FME_URL_V3"
        value = var.plateauview.fme_url_v3
      }

      env {
        name  = "REEARTH_PLATEAUVIEW_OPINION_TO"
        value = var.plateauview.option_to
      }

      env {
        name  = "REEARTH_PLATEAUVIEW_OPINION_FROM"
        value = var.plateauview.option_from
      }
    }

    scaling {
      max_instance_count = 10
    }
  }


  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }

  depends_on = [
    google_secret_manager_secret_version.plateauview_ckan_token,
    google_secret_manager_secret_version.plateauview_cms_token,
    google_secret_manager_secret_version.plateauview_fme_token,
    google_secret_manager_secret_version.plateauview_secret,
    google_secret_manager_secret_version.plateauview_sendgrid_api_key
  ]

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
    ]
  }
}
