locals {
  services = [
    "certificatemanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudtasks.googleapis.com",
    "compute.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "pubsub.googleapis.com",
    "redis.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "sts.googleapis.com",
  ]
}

locals {
  auth0_domain = "plateau-test.jp.auth0.com"

  accounts_domain     = "accounts.${var.domain}"
  accounts_api_domain = "api.${local.accounts_domain}"

  cms_domain        = "cms.${var.domain}"
  cms_api_domain    = "api.${local.cms_domain}"
  cms_assets_domain = "assets.${local.cms_domain}"
  cms_worker_domain = "worker.${local.cms_domain}"

  editor_domain        = "editor.${var.domain}"
  editor_api_domain    = "api.${local.editor_domain}"
  editor_static_domain = "static.${local.editor_domain}"

  flow_domain            = "flow.${var.domain}"
  flow_api_domain        = "api.${local.flow_domain}"
  flow_subscriber_domain = "sub.${local.flow_domain}"
  flow_websocket_domain  = "ws.${local.flow_domain}"

  cerbos_domain          = "cerbos.${var.domain}"
  geo_domain             = "geo.${var.domain}"
  plateauview_api_domain = "api.${var.domain}"
  tiles_domain           = "tiles.${var.domain}"
}

locals {
  plateau_tiles = {
    roles = [
      # Required permission for Node Problem Detector.
      "roles/monitoring.metricWriter"
    ]
  }
}
