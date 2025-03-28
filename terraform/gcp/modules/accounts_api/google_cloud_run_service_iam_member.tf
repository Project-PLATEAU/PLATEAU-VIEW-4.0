resource "google_cloud_run_service_iam_member" "reearth_accounts_api" {
  project  = google_cloud_run_v2_service.reearth_accounts_api.project
  location = google_cloud_run_v2_service.reearth_accounts_api.location
  service  = google_cloud_run_v2_service.reearth_accounts_api.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
