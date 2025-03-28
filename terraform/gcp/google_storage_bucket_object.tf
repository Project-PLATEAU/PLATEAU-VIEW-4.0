resource "google_storage_bucket_object" "cerbos_policy" {
  bucket = google_storage_bucket.cerbos_policy.name
  name   = ".cerbos.yaml"
  source = ".cerbos.yaml"
}
