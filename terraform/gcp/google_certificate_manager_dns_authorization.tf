resource "google_certificate_manager_dns_authorization" "cerbos" {
  project = data.google_project.project.project_id

  description = "Cerbos"
  domain      = local.cerbos_domain
  name        = "cerbos"
}

resource "google_certificate_manager_dns_authorization" "accounts" {
  project = data.google_project.project.project_id

  description = "Accounts"
  domain      = local.accounts_domain
  name        = "accounts"
}

resource "google_certificate_manager_dns_authorization" "plateau_reearth" {
  project = data.google_project.project.project_id
  name    = "wildcard-dns-auth"
  domain  = "reearth.plateau.dev.reearth.io"
}

resource "google_certificate_manager_dns_authorization" "plateau_cms" {
  project = data.google_project.project.project_id
  name    = "plateau-cms"
  domain  = local.cms_domain
}

resource "google_certificate_manager_dns_authorization" "plateau_editor" {
  project = data.google_project.project.project_id
  name    = "editor"
  domain  = local.editor_domain
}

resource "google_certificate_manager_dns_authorization" "plateau_geo" {
  project = data.google_project.project.project_id
  name    = "plateau-geo"
  domain  = local.geo_domain
}

resource "google_certificate_manager_dns_authorization" "plateau_api" {
  project = data.google_project.project.project_id
  name    = "plateau-api"
  domain  = local.plateauview_api_domain
}

resource "google_certificate_manager_dns_authorization" "plateau_flow" {
  project = data.google_project.project.project_id

  description = "Plateau Flow"
  domain      = local.flow_domain
  name        = "plateau-flow"
}
