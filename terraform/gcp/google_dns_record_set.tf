resource "google_dns_record_set" "plateau_reeearth_cms_acme_challenge_cname" {
  project = data.google_project.project.project_id

  name         = google_certificate_manager_dns_authorization.plateau_cms.dns_resource_record[0].name
  managed_zone = google_dns_managed_zone.zone.name
  rrdatas      = [google_certificate_manager_dns_authorization.plateau_cms.dns_resource_record[0].data]
  type         = google_certificate_manager_dns_authorization.plateau_cms.dns_resource_record[0].type
  ttl          = 300
}

resource "google_dns_record_set" "plateau_editor_acme_challenge_cname" {
  project = data.google_project.project.project_id

  name         = google_certificate_manager_dns_authorization.plateau_editor.dns_resource_record[0].name
  managed_zone = google_dns_managed_zone.zone.name
  rrdatas      = [google_certificate_manager_dns_authorization.plateau_editor.dns_resource_record[0].data]
  type         = google_certificate_manager_dns_authorization.plateau_editor.dns_resource_record[0].type
  ttl          = 300
}

resource "google_dns_record_set" "plateau_geo_acme_challenge_cname" {
  project = data.google_project.project.project_id

  name         = google_certificate_manager_dns_authorization.plateau_geo.dns_resource_record[0].name
  managed_zone = google_dns_managed_zone.zone.name
  rrdatas      = [google_certificate_manager_dns_authorization.plateau_geo.dns_resource_record[0].data]
  type         = google_certificate_manager_dns_authorization.plateau_geo.dns_resource_record[0].type
  ttl          = 300
}

resource "google_dns_record_set" "plateau_tiles_acme_challenge_cname" {
  project = data.google_project.project.project_id

  name         = google_certificate_manager_dns_authorization.plateau_tiles.dns_resource_record[0].name
  managed_zone = google_dns_managed_zone.zone.name
  rrdatas      = [google_certificate_manager_dns_authorization.plateau_tiles.dns_resource_record[0].data]
  type         = google_certificate_manager_dns_authorization.plateau_tiles.dns_resource_record[0].type
  ttl          = 300
}

resource "google_dns_record_set" "plateau_api_acme_challenge_cname" {
  project = data.google_project.project.project_id

  name         = google_certificate_manager_dns_authorization.plateau_api.dns_resource_record[0].name
  managed_zone = google_dns_managed_zone.zone.name
  rrdatas      = [google_certificate_manager_dns_authorization.plateau_api.dns_resource_record[0].data]
  type         = google_certificate_manager_dns_authorization.plateau_api.dns_resource_record[0].type
  ttl          = 300
}

resource "google_dns_record_set" "plateau_flow_acme_challenge_cname" {
  project = data.google_project.project.project_id

  name         = google_certificate_manager_dns_authorization.plateau_flow.dns_resource_record[0].name
  managed_zone = google_dns_managed_zone.zone.name
  rrdatas      = [google_certificate_manager_dns_authorization.plateau_flow.dns_resource_record[0].data]
  type         = google_certificate_manager_dns_authorization.plateau_flow.dns_resource_record[0].type
  ttl          = 300
}

resource "google_dns_record_set" "api" {
  project = data.google_project.project.project_id
  name    = "${local.cms_api_domain}."
  type    = "CNAME"
  ttl     = 60

  managed_zone = google_dns_managed_zone.zone.name
  rrdatas      = ["${local.cms_domain}."]
}

resource "google_dns_record_set" "app" {
  project      = data.google_project.project.project_id
  name         = "${local.cms_domain}."
  type         = "A"
  ttl          = 60
  managed_zone = google_dns_managed_zone.zone.name
  rrdatas      = [google_compute_global_address.cms.address]
}

resource "google_dns_record_set" "assets" {
  project = data.google_project.project.project_id
  name    = "${local.cms_assets_domain}."
  type    = "CNAME"
  ttl     = 60

  managed_zone = google_dns_managed_zone.zone.name
  rrdatas      = ["${local.cms_domain}."]
}

# resource "google_dns_record_set" "plateauview_geo" {
#   project = data.google_project.project.project_id
#   name    = "${local.geo_domain}."
#   type    = "CNAME"
#   ttl     = 60

#   managed_zone = data.google_dns_managed_zone.dns.name
#   rrdatas      = ["ghs.googlehosted.com."]
# }

resource "google_dns_record_set" "plateauview_geo" {
  project = data.google_project.project.project_id
  name    = "${local.geo_domain}."
  type    = "CNAME"
  ttl     = 60

  managed_zone = google_dns_managed_zone.zone.name
  rrdatas      = ["${local.cms_domain}."]
}

resource "google_dns_record_set" "plateauview_tiles" {
  project = data.google_project.project.project_id
  name    = "${local.tiles_domain}."
  type    = "CNAME"
  ttl     = 60

  managed_zone = google_dns_managed_zone.zone.name
  rrdatas      = ["${local.cms_domain}."]
}

resource "google_dns_record_set" "worker" {
  project = data.google_project.project.project_id
  name    = "${local.cms_worker_domain}."
  type    = "CNAME"
  ttl     = 60

  managed_zone = google_dns_managed_zone.zone.name
  rrdatas      = ["${local.cms_domain}."]
}


resource "google_dns_record_set" "editor" {
  project      = data.google_project.project.project_id
  name         = "${local.editor_domain}."
  type         = "A"
  ttl          = 60
  managed_zone = google_dns_managed_zone.zone.name
  rrdatas      = [google_compute_global_address.editor.address]
}

resource "google_dns_record_set" "editor_api" {
  project = data.google_project.project.project_id
  name    = "${local.editor_api_domain}."
  type    = "CNAME"
  ttl     = 60

  managed_zone = google_dns_managed_zone.zone.name
  rrdatas      = ["${local.editor_domain}."]
}

resource "google_dns_record_set" "editor_static" {
  project = data.google_project.project.project_id
  name    = "${local.editor_static_domain}."
  type    = "CNAME"
  ttl     = 60

  managed_zone = google_dns_managed_zone.zone.name
  rrdatas      = ["${local.editor_domain}."]
}

resource "google_dns_record_set" "editor_publish" {
  project = data.google_project.project.project_id
  name    = "*.${local.editor_domain}."
  type    = "CNAME"
  ttl     = 60

  managed_zone = google_dns_managed_zone.zone.name
  rrdatas      = ["${local.editor_domain}."]
}

resource "google_dns_record_set" "plateau_api" {
  project = data.google_project.project.project_id
  name    = "${local.plateauview_api_domain}."
  type    = "A"
  ttl     = 60

  managed_zone = google_dns_managed_zone.zone.name
  rrdatas      = [google_compute_global_address.plateau_api.address]

}

resource "google_dns_record_set" "plateau_flow_api_a" {
  project = data.google_project.project.project_id

  name         = "${local.flow_api_domain}."
  managed_zone = google_dns_managed_zone.zone.name
  rrdatas = [
    google_compute_global_address.plateau_flow.address
  ]
  type = "A"
  ttl  = 60
}

resource "google_dns_record_set" "plateau_flow_ui_a" {
  project = data.google_project.project.project_id

  name         = "${local.flow_domain}."
  managed_zone = google_dns_managed_zone.zone.name
  rrdatas = [
    google_compute_global_address.plateau_flow.address
  ]
  type = "A"
  ttl  = 60
}

resource "google_dns_record_set" "plateau_flow_subscriber_a" {
  project = data.google_project.project.project_id

  name         = "${local.flow_subscriber_domain}."
  managed_zone = google_dns_managed_zone.zone.name
  rrdatas = [
    google_compute_global_address.plateau_flow.address,
  ]
  type = "A"
  ttl  = 60
}

resource "google_dns_record_set" "plateau_flow_websocket_a" {
  project = data.google_project.project.project_id

  name         = "${local.flow_websocket_domain}."
  managed_zone = google_dns_managed_zone.zone.name
  rrdatas = [
    google_compute_global_address.plateau_flow.address,
  ]
  type = "A"
  ttl  = 60
}
