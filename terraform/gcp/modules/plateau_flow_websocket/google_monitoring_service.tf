resource "google_monitoring_service" "reearth_flow_websocket" {
  project      = data.google_project.project.project_id
  service_id   = "${var.name}-${var.region}" # This has to be unique across the project so we add the region suffix.
  display_name = var.name

  basic_service {
    service_type = "CLOUD_RUN"
    service_labels = {
      location     = google_cloud_run_v2_service.reearth_flow_websocket.location
      service_name = google_cloud_run_v2_service.reearth_flow_websocket.name
    }
  }
}
