resource "google_monitoring_service" "reearth_flow_api" {
  project      = data.google_project.project.project_id
  service_id   = "reearth-flow-api-${var.region}" # This has to be unique across the project so we add the region suffix.
  display_name = "reearth-flow-api"

  basic_service {
    service_type = "CLOUD_RUN"
    service_labels = {
      location     = google_cloud_run_v2_service.reearth_flow_api.location
      service_name = google_cloud_run_v2_service.reearth_flow_api.name
    }
  }
}
