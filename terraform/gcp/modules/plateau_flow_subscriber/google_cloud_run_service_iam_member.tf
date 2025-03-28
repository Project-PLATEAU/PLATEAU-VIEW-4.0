resource "google_cloud_run_service_iam_member" "reearth_flow_subscriber_noauth" {
  project  = google_cloud_run_v2_service.reearth_flow_subscriber.project
  location = google_cloud_run_v2_service.reearth_flow_subscriber.location
  service  = google_cloud_run_v2_service.reearth_flow_subscriber.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
