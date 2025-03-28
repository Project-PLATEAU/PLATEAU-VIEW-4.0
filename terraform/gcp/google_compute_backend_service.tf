resource "google_compute_backend_service" "accounts_api" {
  project = data.google_project.project.project_id
  name    = "reearth-accounts-api"

  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = module.accounts_api.network_endpoint_group.id
  }
}

resource "google_compute_backend_service" "cerbos" {
  project = data.google_project.project.project_id
  name    = "cerbos"

  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTP2"

  backend {
    group = module.cerbos.network_endpoint_group.id
  }
}

resource "google_compute_backend_service" "cms_api" {
  project = data.google_project.project.project_id
  name    = "cms-api"

  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = module.cms_api.network_endpoint_group.id
  }
}

resource "google_compute_backend_service" "cms_web" {
  project = data.google_project.project.project_id
  name    = "cms-web"

  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = module.cms_web.network_endpoint_group.id
  }
}

resource "google_compute_backend_service" "cms_worker" {
  project = data.google_project.project.project_id
  name    = "cms-worker"

  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = module.cms_worker.network_endpoint_group.id
  }
}

resource "google_compute_backend_service" "plateau_tiles" {
  project = data.google_project.project.project_id

  connection_draining_timeout_sec = 30
  enable_cdn                      = true
  name                            = "plateau-tiles"
  timeout_sec                     = 30

  backend {
    group = module.plateauview_tiles.compute_instance_group_manager.instance_group
  }

  cdn_policy {
    cache_mode                   = "CACHE_ALL_STATIC"
    client_ttl                   = 60 * 60 * 24 * 30  # 30 days
    default_ttl                  = 60 * 60 * 24 * 30  # 30 days
    max_ttl                      = 60 * 60 * 24 * 365 # 1 year
    signed_url_cache_max_age_sec = 60 * 60 * 24 * 30  # 30 days
  }

  health_checks = [module.plateauview_tiles.compute_health_check.id]

  log_config {
    enable = true
  }
}

resource "google_compute_backend_service" "editor_api" {
  project = data.google_project.project.project_id
  name    = "editor-api"

  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = module.editor_api.network_endpoint_group.id
  }
}

resource "google_compute_backend_service" "editor_web" {
  project = data.google_project.project.project_id
  name    = "editor-web"

  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = module.editor_web.network_endpoint_group.id
  }
}

resource "google_compute_backend_service" "plateau_geo" {
  project = data.google_project.project.project_id
  name    = "plateauview-geo"

  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = module.plateauview_geo.network_endpoint_group.id
  }
}


resource "google_compute_backend_service" "plateau_api" {
  project = data.google_project.project.project_id
  name    = "plateauview-api"

  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = module.plateauview_api.network_endpoint_group.id
  }
}

resource "google_compute_backend_service" "plateau_flow_api" {
  project = data.google_project.project.project_id

  name                            = "plateau-flow-api"
  load_balancing_scheme           = "EXTERNAL_MANAGED"
  port_name                       = "http"
  protocol                        = "HTTP2"
  connection_draining_timeout_sec = 300

  backend {
    group           = module.plateau_flow_api.network_endpoint_group.id
    max_utilization = 0.8
  }

  log_config {
    enable      = true
    sample_rate = "1"
  }

  session_affinity        = "GENERATED_COOKIE"
  affinity_cookie_ttl_sec = 7200 # 2 hours
}

resource "google_compute_backend_service" "plateau_flow_subscriber" {
  project = data.google_project.project.project_id

  affinity_cookie_ttl_sec         = 7200 # 2 hours
  connection_draining_timeout_sec = 300
  enable_cdn                      = false
  load_balancing_scheme           = "EXTERNAL_MANAGED"
  name                            = "plateau-flow-subscriber"
  port_name                       = "http"
  protocol                        = "HTTP2"
  session_affinity                = "GENERATED_COOKIE"
  timeout_sec                     = "30"

  backend {
    group           = module.plateau_flow_subscriber.network_endpoint_group.id
    max_utilization = 0.8
  }

  log_config {
    enable      = true
    sample_rate = "1"
  }
}

resource "google_compute_backend_service" "plateau_flow_web" {
  project = data.google_project.project.project_id

  load_balancing_scheme = "EXTERNAL_MANAGED"
  name                  = "plateau-flow-web"
  port_name             = "http"
  protocol              = "HTTPS"

  backend {
    group = module.plateau_flow_web_us_central1.network_endpoint_group.id
  }
}

resource "google_compute_backend_service" "plateau_flow_websocket" {
  project = data.google_project.project.project_id

  affinity_cookie_ttl_sec         = 7200 # 2 hours
  connection_draining_timeout_sec = 300
  enable_cdn                      = false
  load_balancing_scheme           = "EXTERNAL_MANAGED"
  name                            = "plateau-flow-websocket"
  port_name                       = "http"
  protocol                        = "HTTP2"
  session_affinity                = "GENERATED_COOKIE"
  timeout_sec                     = "30"

  backend {
    group           = module.plateau_flow_websocket.network_endpoint_group.id
    max_utilization = 0.8
  }

  log_config {
    enable      = true
    sample_rate = "1"
  }
}
