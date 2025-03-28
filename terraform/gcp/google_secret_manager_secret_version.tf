resource "google_secret_manager_secret_version" "cms_auth0_client_secret" {
  secret      = google_secret_manager_secret.cms_auth0_client_secret.id
  secret_data = module.auth0_cms.client_m2m.client_secret
}

resource "google_secret_manager_secret_version" "cms_auth0_signup_secret" {
  secret      = google_secret_manager_secret.cms_auth0_signup_secret.id
  secret_data = module.auth0_cms.client_m2m.client_id
}

resource "google_secret_manager_secret_version" "editor_auth0_client_secret" {
  secret      = google_secret_manager_secret.editor_auth0_client_secret.id
  secret_data = module.auth0_editor.client_m2m.client_secret
}

resource "google_secret_manager_secret_version" "editor_auth0_signup_secret" {
  secret      = google_secret_manager_secret.editor_auth0_signup_secret.id
  secret_data = module.auth0_editor.client_m2m.client_id
}

resource "google_secret_manager_secret_version" "flow_auth0_client_secret" {
  secret      = google_secret_manager_secret.flow_auth0_client_secret.id
  secret_data = module.auth0_flow.client_m2m.client_secret
}

resource "google_secret_manager_secret_version" "flow_auth0_signup_secret" {
  secret      = google_secret_manager_secret.flow_auth0_signup_secret.id
  secret_data = module.auth0_flow.client_m2m.client_id
}

resource "google_secret_manager_secret_version" "cms_db" {
  secret      = google_secret_manager_secret.cms_db.id
  secret_data = var.mongodb_connection_string
}

resource "google_secret_manager_secret_version" "editor_db" {
  secret      = google_secret_manager_secret.editor_db.id
  secret_data = var.mongodb_connection_string
}

resource "google_secret_manager_secret_version" "accounts_db" {
  secret      = google_secret_manager_secret.accounts_db.id
  secret_data = var.mongodb_connection_string
}

resource "google_secret_manager_secret_version" "flow_db" {
  secret      = google_secret_manager_secret.flow_db.id
  secret_data = var.mongodb_connection_string
}

resource "google_secret_manager_secret_version" "cesium_ion_token" {
  secret      = google_secret_manager_secret.cesium_ion_token.id
  secret_data = var.cesium_ion_access_token
}

resource "google_secret_manager_secret_version" "plateau_flow_redis_url" {
  secret      = google_secret_manager_secret.plateau_flow_redis_url.id
  secret_data = "redis://:${google_redis_instance.plateau_flow.auth_string}@${google_redis_instance.plateau_flow.host}:${google_redis_instance.plateau_flow.port}/0"
}
