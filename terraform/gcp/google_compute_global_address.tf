resource "google_compute_global_address" "accounts" {
  project = data.google_project.project.project_id
  name    = "accounts"
}

resource "google_compute_global_address" "cerbos" {
  project = data.google_project.project.project_id
  name    = "cerbos"
}

resource "google_compute_global_address" "cms" {
  project = data.google_project.project.project_id
  name    = "cms"
}

resource "google_compute_global_address" "cms_cloudbuild" {
  provider = google-beta

  project = data.google_project.project.project_id
  name    = "cms-cloudbuild"

  address_type  = "INTERNAL"
  network       = data.google_compute_network.default.id
  prefix_length = 16
  purpose       = "VPC_PEERING"
}

resource "google_compute_global_address" "editor" {
  project = data.google_project.project.project_id
  name    = "editor"
}

resource "google_compute_global_address" "plateau_geo" {
  project = data.google_project.project.project_id
  name    = "plateau-geo"
}


resource "google_compute_global_address" "plateau_api" {
  project = data.google_project.project.project_id
  name    = "plateau-api"
}

resource "google_compute_global_address" "plateau_flow" {
  project = data.google_project.project.project_id
  name    = "plateau-flow"
}

resource "google_compute_global_address" "plateau_flow_subscriber" {
  provider = google-beta

  project = data.google_project.project.project_id
  name    = "plateau-flow-subscriber"

  address_type  = "INTERNAL"
  description   = "Use for VPC peering between PLATEAU Flow subscriber and the Google Cloud"
  network       = data.google_compute_network.default.id
  prefix_length = 16 # Ref: https://cloud.google.com/memorystore/docs/redis/establish-connection#gcloud
  purpose       = "VPC_PEERING"
}

resource "google_compute_global_address" "plateau_flow_websocket" {
  provider = google-beta

  project = data.google_project.project.project_id
  name    = "plateau-flow-websocket"

  address_type  = "INTERNAL"
  description   = "Use for VPC peering between PLATEAU Flow websocket and the Google Cloud"
  network       = data.google_compute_network.default.id
  prefix_length = 16 # Ref: https://cloud.google.com/memorystore/docs/redis/establish-connection#gcloud
  purpose       = "VPC_PEERING"
}
