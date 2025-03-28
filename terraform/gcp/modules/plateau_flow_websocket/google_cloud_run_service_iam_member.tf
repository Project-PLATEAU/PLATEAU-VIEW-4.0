resource "google_cloud_run_service_iam_member" "reearth_flow_websocket_noauth" {
  project  = google_cloud_run_v2_service.reearth_flow_websocket.project
  location = google_cloud_run_v2_service.reearth_flow_websocket.location
  service  = google_cloud_run_v2_service.reearth_flow_websocket.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
