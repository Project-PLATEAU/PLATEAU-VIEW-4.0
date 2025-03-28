resource "google_cloud_run_service_iam_member" "cerbos" {
  project  = google_cloud_run_v2_service.cerbos.project
  location = google_cloud_run_v2_service.cerbos.location
  service  = google_cloud_run_v2_service.cerbos.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
