resource "google_storage_bucket" "cerbos_policy" {
  project = data.google_project.project.project_id

  location      = var.gcp_region
  name          = "cerbos-policy"
  storage_class = "STANDARD"
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
