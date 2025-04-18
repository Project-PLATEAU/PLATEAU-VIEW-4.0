resource "google_storage_bucket" "app_tile_cache" {
  project       = data.google_project.project.project_id
  name          = "${var.prefix}-app-tile-cache"
  location      = "ASIA"
  storage_class = "MULTI_REGIONAL"
}

resource "google_storage_bucket" "cerbos_policy" {
  project = data.google_project.project.project_id

  location      = var.gcp_region
  name          = "cerbos-policy"
  storage_class = "STANDARD"
}

resource "google_storage_bucket" "cms_assets" {
  project       = data.google_project.project.project_id
  name          = "${var.prefix}-cms-assets-bucket"
  location      = "ASIA"
  storage_class = "MULTI_REGIONAL"

  cors {
    max_age_seconds = 60
    method = [
      "GET",
      "PATCH",
      "POST",
      "PUT",
      "HEAD",
      "OPTIONS",
    ]
    origin = [
      "*"
    ]
    response_header = [
      "Content-Type",
      "Access-Control-Allow-Origin"
    ]
  }

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }
}

resource "google_storage_bucket" "terraform" {
  project       = data.google_project.project.project_id
  location      = "asia-northeast1"
  name          = var.gcs_bucket
  storage_class = "STANDARD"
}

resource "google_storage_bucket" "plateau_flow_bucket" {
  project = data.google_project.project.project_id

  name     = "plateau-flow-oss-bucket"
  location = "asia-northeast1"
}

resource "google_storage_bucket" "plateau_flow_websocket_bucket" {
  project = data.google_project.project.project_id

  name     = "plateau-flow-websocket-bucket"
  location = "asia-northeast1"
}
