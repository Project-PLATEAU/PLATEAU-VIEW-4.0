resource "google_monitoring_uptime_check_config" "reearth_flow_api" {
  project = data.google_project.project.project_id

  display_name = "Re:Earth Flow API Cloud Run Uptime Check (${var.region})"
  period       = "900s" # 15 mins, maximum. Default is 300s (5 mins).
  timeout      = "60s"

  http_check {
    # Ref: https://github.com/reearth/reearth-flow/blob/32c5a687141c298d08417743d0290f7ac194c7c6/api/internal/app/app.go#L92-L93
    path    = "/api/ping"
    port    = "443"
    use_ssl = true

    # Not supported for Cloud Run uptime check
    validate_ssl = false

    accepted_response_status_codes {
      status_class = "STATUS_CLASS_2XX"
    }
  }

  monitored_resource {
    type = "cloud_run_revision"
    labels = {
      location : google_cloud_run_v2_service.reearth_flow_api.location
      project_id : google_cloud_run_v2_service.reearth_flow_api.project
      service_name : google_cloud_run_v2_service.reearth_flow_api.name
    }
  }

  lifecycle {
    ignore_changes = [
      monitored_resource[0].labels
    ]
  }
}
