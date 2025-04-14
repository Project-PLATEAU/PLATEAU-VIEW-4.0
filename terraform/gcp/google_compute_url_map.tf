resource "google_compute_url_map" "cerbos" {
  project = data.google_project.project.project_id

  name        = "cerbos"
  description = "Url map for Cerbos"

  default_service = google_compute_backend_service.cerbos.id

  host_rule {
    hosts        = [local.cerbos_domain]
    path_matcher = "cerbos"
  }

  path_matcher {
    name            = "cerbos"
    default_service = google_compute_backend_service.cerbos.id
  }
}

resource "google_compute_url_map" "accounts" {
  project = data.google_project.project.project_id

  name        = "reearth-accounts"
  description = "Url map for Accounts"

  default_service = google_compute_backend_service.accounts_api.id

  host_rule {
    hosts        = ["api.${local.accounts_domain}"]
    path_matcher = "api"
  }

  path_matcher {
    name            = "api"
    default_service = google_compute_backend_service.accounts_api.id
  }
}

resource "google_compute_url_map" "plateau_cms" {
  project = data.google_project.project.project_id

  name        = "plateau-cms"
  description = "Url map for Re:Earth Plateau"

  default_service = google_compute_backend_service.cms_api.id

  host_rule {
    hosts        = [local.cms_api_domain]
    path_matcher = "api"
  }

  path_matcher {
    name            = "api"
    default_service = google_compute_backend_service.cms_api.id
  }

  host_rule {
    hosts        = [local.cms_assets_domain]
    path_matcher = "assets"
  }

  path_matcher {
    name            = "assets"
    default_service = module.cms_api.assets_backend_service.id
  }

  host_rule {
    hosts        = [local.cms_domain]
    path_matcher = "web"
  }

  path_matcher {
    name            = "web"
    default_service = google_compute_backend_service.cms_web.id
  }

  host_rule {
    hosts        = [local.cms_worker_domain]
    path_matcher = "worker"
  }

  path_matcher {
    name            = "worker"
    default_service = google_compute_backend_service.cms_worker.id
  }
}

resource "google_compute_url_map" "editor" {
  project = data.google_project.project.project_id

  name        = "plateau-editor"
  description = "Url map for Re:Earth editor"

  default_service = google_compute_backend_service.editor_web.id

  host_rule {
    hosts = [
      local.editor_api_domain,

    ]
    path_matcher = "api"
  }

  path_matcher {
    name            = "api"
    default_service = google_compute_backend_service.editor_api.id
  }

  host_rule {
    hosts = [
      local.editor_domain,
    ]
    path_matcher = "web"
  }

  path_matcher {
    name            = "web"
    default_service = google_compute_backend_service.editor_web.id
  }

  host_rule {
    hosts        = [local.editor_static_domain]
    path_matcher = "static"
  }

  path_matcher {
    name            = "static"
    default_service = module.editor_api.static_backend_service.id
  }

  host_rule {
    hosts = [
      "${var.editor_project_name}.${local.editor_domain}", # Publish 
    ]
    path_matcher = "publish"
  }

  path_matcher {
    name            = "publish"
    default_service = google_compute_backend_service.editor_api.id
    path_rule {
      paths = ["/"]
      route_action {
        url_rewrite {
          host_rewrite        = local.editor_domain
          path_prefix_rewrite = "/published.html?alias=${var.editor_project_name}"
        }
        weighted_backend_services {
          backend_service = google_compute_backend_service.editor_api.id
          weight          = 100
        }
      }
    }
    path_rule {
      paths = ["/data.json"]
      route_action {
        url_rewrite {
          host_rewrite        = local.editor_api_domain
          path_prefix_rewrite = "/api/published_data/${var.editor_project_name}"
        }
        weighted_backend_services {
          backend_service = google_compute_backend_service.editor_api.id
          weight          = 100
        }
      }
    }
    path_rule {
      paths = ["/*"]
      route_action {
        url_rewrite {
          host_rewrite = local.editor_domain
        }
        weighted_backend_services {
          backend_service = google_compute_backend_service.editor_api.id
          weight          = 100
        }
      }
    }





    # route_rules {
    #   match_rules {
    #     path_template_match = "/*"
    #   }
    #   service = google_compute_backend_service.editor_api.id
    #   priority = 1
    #   route_action {
    #     url_rewrite {
    #       host_rewrite = local.editor_domain
    #       path_template_rewrite = "/published.html?alias=${var.editor_project_name}"
    #     }
    #   }
    # }
  }
}

resource "google_compute_url_map" "plateau_geo" {
  project = data.google_project.project.project_id
  name    = "plateau-geo"

  default_service = google_compute_backend_service.plateau_geo.id

  host_rule {
    hosts        = [local.geo_domain]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.plateau_geo.id
  }
}


resource "google_compute_url_map" "plateau_api" {
  project = data.google_project.project.project_id
  name    = "plateau-api"

  default_service = google_compute_backend_service.plateau_api.id

  host_rule {
    hosts        = [local.plateauview_api_domain]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.plateau_api.id
  }
}

resource "google_compute_url_map" "plateau_flow" {
  project = data.google_project.project.project_id

  name        = "plateau-flow"
  description = "Url map for PLATEAU Flow"

  default_service = google_compute_backend_service.plateau_flow_api.id

  host_rule {
    hosts        = [local.flow_api_domain]
    path_matcher = "api"
  }

  path_matcher {
    name            = "api"
    default_service = google_compute_backend_service.plateau_flow_api.id
  }

  host_rule {
    hosts        = [local.flow_subscriber_domain]
    path_matcher = "subscriber"
  }

  path_matcher {
    name            = "subscriber"
    default_service = google_compute_backend_service.plateau_flow_subscriber.id
  }

  host_rule {
    hosts        = [local.flow_domain]
    path_matcher = "web"
  }

  path_matcher {
    name            = "web"
    default_service = google_compute_backend_service.plateau_flow_web.id
  }

  host_rule {
    hosts        = [local.flow_websocket_domain]
    path_matcher = "websocket"
  }

  path_matcher {
    name            = "websocket"
    default_service = google_compute_backend_service.plateau_flow_websocket.id
  }
}
