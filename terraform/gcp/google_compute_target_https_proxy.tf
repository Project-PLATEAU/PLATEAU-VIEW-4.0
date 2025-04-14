resource "google_compute_target_https_proxy" "cerbos" {
  project = data.google_project.project.project_id

  name            = "cerbos"
  certificate_map = "//certificatemanager.googleapis.com/${google_certificate_manager_certificate_map.cerbos.id}"
  url_map         = google_compute_url_map.cerbos.id
}

resource "google_compute_target_https_proxy" "accounts" {
  project = data.google_project.project.project_id

  name            = "reearth-accounts"
  certificate_map = "//certificatemanager.googleapis.com/${google_certificate_manager_certificate_map.accounts.id}"
  url_map         = google_compute_url_map.accounts.id
}

resource "google_compute_target_https_proxy" "plateau_cms" {
  project = data.google_project.project.project_id

  certificate_map = "//certificatemanager.googleapis.com/${google_certificate_manager_certificate_map.plateau_cms.id}"
  name            = "plateau-cms"
  url_map         = google_compute_url_map.plateau_cms.id
}

resource "google_compute_target_https_proxy" "editor" {
  project = data.google_project.project.project_id

  name            = "plateau-editor"
  certificate_map = "//certificatemanager.googleapis.com/${google_certificate_manager_certificate_map.plateau_editor.id}"
  url_map         = google_compute_url_map.editor.id
}

resource "google_compute_target_https_proxy" "plateau_geo" {
  project = data.google_project.project.project_id

  certificate_map = "//certificatemanager.googleapis.com/${google_certificate_manager_certificate_map.plateau_geo.id}"
  name            = "plateau-geo"
  url_map         = google_compute_url_map.plateau_geo.id
}

resource "google_compute_target_https_proxy" "plateau_api" {
  project = data.google_project.project.project_id

  certificate_map = "//certificatemanager.googleapis.com/${google_certificate_manager_certificate_map.plateau_api.id}"
  name            = "plateau-api"
  url_map         = google_compute_url_map.plateau_api.id
}

resource "google_compute_target_https_proxy" "plateau_flow" {
  project = data.google_project.project.project_id

  name            = "plateau-flow-web"
  certificate_map = "//certificatemanager.googleapis.com/${google_certificate_manager_certificate_map.plateau_flow.id}"
  url_map         = google_compute_url_map.plateau_flow.id
}
