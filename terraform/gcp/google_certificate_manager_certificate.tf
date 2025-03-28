resource "google_certificate_manager_certificate" "accounts" {
  project = data.google_project.project.project_id

  name        = "accounts"
  description = "Accounts certificates"

  managed {
    dns_authorizations = [
      google_certificate_manager_dns_authorization.accounts.id,
    ]

    domains = [
      google_certificate_manager_dns_authorization.accounts.domain,
      "*.${google_certificate_manager_dns_authorization.accounts.domain}"
    ]
  }
}

resource "google_certificate_manager_certificate" "cerbos" {
  project = data.google_project.project.project_id

  name        = "cerbos"
  description = "Cerbos certificates"

  managed {
    dns_authorizations = [
      google_certificate_manager_dns_authorization.cerbos.id,
    ]

    domains = [
      google_certificate_manager_dns_authorization.cerbos.domain,
    ]
  }
}

resource "google_certificate_manager_certificate" "plateau_api" {
  project = data.google_project.project.project_id
  name    = "plateau-api"

  managed {
    domains = [
      google_certificate_manager_dns_authorization.plateau_api.domain,
    ]

    dns_authorizations = [
      google_certificate_manager_dns_authorization.plateau_api.id,
    ]
  }
}

resource "google_certificate_manager_certificate" "plateau_cms" {
  project = data.google_project.project.project_id
  name    = "plateau-cms"

  managed {
    domains = [
      google_certificate_manager_dns_authorization.plateau_cms.domain,
      "*.${google_certificate_manager_dns_authorization.plateau_cms.domain}"
    ]

    dns_authorizations = [
      google_certificate_manager_dns_authorization.plateau_cms.id,
    ]
  }
}

resource "google_certificate_manager_certificate" "plateau_editor" {
  project = data.google_project.project.project_id

  name = "plateau-editor"

  managed {
    dns_authorizations = [
      google_certificate_manager_dns_authorization.plateau_editor.id,
    ]

    domains = [
      google_certificate_manager_dns_authorization.plateau_editor.domain,
      "*.${google_certificate_manager_dns_authorization.plateau_editor.domain}"
    ]
  }
}

resource "google_certificate_manager_certificate" "plateau_flow" {
  project = data.google_project.project.project_id

  name        = "plateau-flow"
  description = "Plateau Flow certificates"

  managed {
    dns_authorizations = [
      google_certificate_manager_dns_authorization.plateau_flow.id,
    ]

    domains = [
      google_certificate_manager_dns_authorization.plateau_flow.domain,
      "*.${google_certificate_manager_dns_authorization.plateau_flow.domain}"
    ]
  }
}

resource "google_certificate_manager_certificate" "plateau_geo" {
  project = data.google_project.project.project_id
  name    = "plateau-geo"

  managed {
    domains = [
      google_certificate_manager_dns_authorization.plateau_geo.domain,
    ]

    dns_authorizations = [
      google_certificate_manager_dns_authorization.plateau_geo.id,
    ]
  }
}

resource "google_certificate_manager_certificate" "plateau_reearth" {
  project = data.google_project.project.project_id
  name    = "plateau-reearth"

  managed {
    domains = [
      google_certificate_manager_dns_authorization.plateau_reearth.domain,
      "*.${google_certificate_manager_dns_authorization.plateau_reearth.domain}"
    ]

    dns_authorizations = [
      google_certificate_manager_dns_authorization.plateau_reearth.id,
    ]
  }
}

resource "google_certificate_manager_certificate" "plateau_tiles" {
  project = data.google_project.project.project_id
  name    = "plateau-tiles"

  managed {
    domains = [
      google_certificate_manager_dns_authorization.plateau_tiles.domain,
    ]

    dns_authorizations = [
      google_certificate_manager_dns_authorization.plateau_tiles.id,
    ]
  }
}
