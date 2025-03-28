output "url" {
  value = google_cloud_run_v2_service.chiitiler.uri
}

output "bucket" {
  value = google_storage_bucket.tile_cache.name
}
