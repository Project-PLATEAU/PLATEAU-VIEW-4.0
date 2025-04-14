resource "google_compute_global_forwarding_rule" "accounts" {
  project = data.google_project.project.project_id

  name                  = "reearth-accounts"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = google_compute_global_address.accounts.id
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.accounts.id
}

resource "google_compute_global_forwarding_rule" "cerbos" {
  project = data.google_project.project.project_id

  name                  = "cerbos"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = google_compute_global_address.cerbos.id
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.cerbos.id
}

resource "google_compute_global_forwarding_rule" "plateau_cms" {
  project               = data.google_project.project.project_id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = google_compute_global_address.cms.address
  name                  = "cms"
  port_range            = "443"
  target                = google_compute_target_https_proxy.plateau_cms.self_link
}

resource "google_compute_global_forwarding_rule" "editor" {
  project = data.google_project.project.project_id

  name                  = "editor"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = google_compute_global_address.editor.id
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.editor.id
}

resource "google_compute_global_forwarding_rule" "plateau_api" {
  project = data.google_project.project.project_id

  name                  = "plateau-api"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = google_compute_global_address.plateau_api.id
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.plateau_api.id
}

resource "google_compute_global_forwarding_rule" "plateau_flow" {
  project = data.google_project.project.project_id

  name                  = "plateau-flow"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = google_compute_global_address.plateau_flow.id
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.plateau_flow.id
}
