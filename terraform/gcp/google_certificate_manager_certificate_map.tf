resource "google_certificate_manager_certificate_map" "accounts" {
  project = data.google_project.project.project_id

  description = "Accounts"
  name        = "accounts"
}

resource "google_certificate_manager_certificate_map" "cerbos" {
  project = data.google_project.project.project_id

  description = "Cerbos"
  name        = "cerbos"
}

resource "google_certificate_manager_certificate_map" "plateau_api" {
  project = data.google_project.project.project_id
  name    = "plateau-api"
}

resource "google_certificate_manager_certificate_map" "plateau_cms" {
  project = data.google_project.project.project_id
  name    = "plateau-cms"
}

resource "google_certificate_manager_certificate_map" "plateau_editor" {
  project = data.google_project.project.project_id
  name    = "plateau-editor"
}

resource "google_certificate_manager_certificate_map" "plateau_flow" {
  project = data.google_project.project.project_id

  description = "Plateau Flow"
  name        = "plateau-flow"
}

resource "google_certificate_manager_certificate_map" "plateau_geo" {
  project = data.google_project.project.project_id
  name    = "plateau-geo"
}

resource "google_certificate_manager_certificate_map" "plateau_reearth" {
  project = data.google_project.project.project_id
  name    = "plateau-reearth"
}
