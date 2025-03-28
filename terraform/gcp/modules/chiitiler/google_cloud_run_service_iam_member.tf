resource "google_cloud_run_service_iam_member" "chiitier" {
  project  = google_cloud_run_v2_service.chiitiler.project
  location = google_cloud_run_v2_service.chiitiler.location
  service  = google_cloud_run_v2_service.chiitiler.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
