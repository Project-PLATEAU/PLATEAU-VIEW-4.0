resource "google_storage_bucket" "tile_cache" {
  project       = data.google_project.project.project_id
  name          = "${var.prefix}-tile-cache"
  location      = "ASIA"
  storage_class = "MULTI_REGIONAL"
}
