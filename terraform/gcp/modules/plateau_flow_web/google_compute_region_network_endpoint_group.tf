resource "google_compute_region_network_endpoint_group" "reearth_flow_web" {
  project               = data.google_project.project.project_id
  name                  = "reearth-flow-web"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = google_cloud_run_v2_service.reearth_flow_web.name
  }
}
