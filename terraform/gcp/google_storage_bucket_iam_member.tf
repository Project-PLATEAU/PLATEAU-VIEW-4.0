
resource "google_storage_bucket_iam_binding" "cms_assets_public_read" {
  bucket = google_storage_bucket.cms_assets.name
  role   = "roles/storage.objectViewer"
  members = [
    "allUsers",
    "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com",
  ]
}

resource "google_storage_bucket_iam_member" "cerbos_is_cerbos_policy_object_admin" {
  bucket = google_storage_bucket.cerbos_policy.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.cerbos.email}"
}

resource "google_storage_bucket_iam_member" "plateau_flow_access" {
  bucket = google_storage_bucket.plateau_flow_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "allUsers"
}

resource "google_storage_bucket_iam_member" "plateau_flow_websocket_access" {
  bucket = google_storage_bucket.plateau_flow_websocket_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "allUsers"
}
