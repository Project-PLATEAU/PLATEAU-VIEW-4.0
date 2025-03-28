resource "google_secret_manager_secret" "cesium_ion_token" {
  project   = data.google_project.project.project_id
  secret_id = "cesium-ion-token"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "editor_auth0_client_secret" {
  project   = data.google_project.project.project_id
  secret_id = "editor-auth0-client-secret"

  replication {
    auto {}
  }
}


resource "google_secret_manager_secret" "editor_auth0_signup_secret" {
  project   = data.google_project.project.project_id
  secret_id = "editor-auth0-signup-secret"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "cms_auth0_client_secret" {
  project   = data.google_project.project.project_id
  secret_id = "cms-auth0-client-secret"

  replication {
    auto {}
  }
}
resource "google_secret_manager_secret" "cms_auth0_signup_secret" {
  project   = data.google_project.project.project_id
  secret_id = "cms-auth0-signup-secret"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "flow_auth0_client_secret" {
  project   = data.google_project.project.project_id
  secret_id = "flow-auth0-client-secret"

  replication {
    auto {}
  }
}
resource "google_secret_manager_secret" "flow_auth0_signup_secret" {
  project   = data.google_project.project.project_id
  secret_id = "flow-auth0-signup-secret"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "cms_db" {
  project   = data.google_project.project.project_id
  secret_id = "cms-db"

  replication {
    auto {}
  }
}
resource "google_secret_manager_secret" "editor_db" {
  project   = data.google_project.project.project_id
  secret_id = "editor-db"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "accounts_db" {
  project   = data.google_project.project.project_id
  secret_id = "account-db"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "flow_db" {
  project   = data.google_project.project.project_id
  secret_id = "flow-db"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "plateau_flow_redis_url" {
  project   = data.google_project.project.project_id
  secret_id = "plateau-flow-redis-url"

  replication {
    auto {}
  }
}
