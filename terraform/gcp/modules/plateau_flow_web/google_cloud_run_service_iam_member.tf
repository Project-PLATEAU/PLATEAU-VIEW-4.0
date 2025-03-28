resource "google_cloud_run_service_iam_member" "reearth_flow_web_noauth" {
  project  = google_cloud_run_v2_service.reearth_flow_web.project
  location = google_cloud_run_v2_service.reearth_flow_web.location
  service  = google_cloud_run_v2_service.reearth_flow_web.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
