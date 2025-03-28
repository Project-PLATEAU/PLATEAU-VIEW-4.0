resource "google_cloud_run_service_iam_member" "reearth_flow_api_noauth" {
  project  = google_cloud_run_v2_service.reearth_flow_api.project
  location = google_cloud_run_v2_service.reearth_flow_api.location
  service  = google_cloud_run_v2_service.reearth_flow_api.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
