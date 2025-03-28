resource "google_secret_manager_secret_iam_member" "cesium_ion_token" {
  for_each = {
    "cms-web"    = google_service_account.cms_web.email
    "editor-web" = google_service_account.editor_web.email
  }

  project   = google_secret_manager_secret.cesium_ion_token.project
  secret_id = google_secret_manager_secret.cesium_ion_token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${each.value}"
}

resource "google_secret_manager_secret_iam_member" "editor_auth0_client_secret" {
  for_each = {
    "editor-api" = google_service_account.editor_api.email
  }

  project   = google_secret_manager_secret.editor_auth0_client_secret.project
  secret_id = google_secret_manager_secret.editor_auth0_client_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${each.value}"
}


resource "google_secret_manager_secret_iam_member" "editor_auth0_signup_secret" {
  for_each = {
    "editor-api" = google_service_account.editor_api.email
  }

  project   = google_secret_manager_secret.editor_auth0_signup_secret.project
  secret_id = google_secret_manager_secret.editor_auth0_signup_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${each.value}"
}

resource "google_secret_manager_secret_iam_member" "cms_auth0_client_secret" {
  for_each = {
    "cms-api" = google_service_account.cms_api.email
  }

  project   = google_secret_manager_secret.cms_auth0_client_secret.project
  secret_id = google_secret_manager_secret.cms_auth0_client_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${each.value}"
}


resource "google_secret_manager_secret_iam_member" "cms_auth0_signup_secret" {
  for_each = {
    "cms-api" = google_service_account.cms_api.email
  }

  project   = google_secret_manager_secret.cms_auth0_signup_secret.project
  secret_id = google_secret_manager_secret.cms_auth0_signup_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${each.value}"
}

resource "google_secret_manager_secret_iam_member" "flow_auth0_client_secret" {
  for_each = {
    "flow-api" = google_service_account.plateau_flow_api.email
  }

  project   = google_secret_manager_secret.flow_auth0_client_secret.project
  secret_id = google_secret_manager_secret.flow_auth0_client_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${each.value}"
}


resource "google_secret_manager_secret_iam_member" "flow_auth0_signup_secret" {
  for_each = {
    "flow-api" = google_service_account.plateau_flow_api.email
  }

  project   = google_secret_manager_secret.flow_auth0_signup_secret.project
  secret_id = google_secret_manager_secret.flow_auth0_signup_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${each.value}"
}

resource "google_secret_manager_secret_iam_member" "cms_db" {
  for_each = {
    # "cloudbuild" = "${data.google_project.project.project_id}@cloudbuild.gserviceaccount.com" # TODO: defaultでは作成されなくなった
    "cms-build"  = google_service_account.cms_cloudbuild.email
    "cms-worker" = google_service_account.cms_worker.email
    "cms-api"    = google_service_account.cms_api.email
  }

  project   = google_secret_manager_secret.cms_db.project
  secret_id = google_secret_manager_secret.cms_db.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${each.value}"
}

resource "google_secret_manager_secret_iam_member" "editor_db" {
  for_each = {
    "editor-api" = google_service_account.editor_api.email
  }

  project   = google_secret_manager_secret.editor_db.project
  secret_id = google_secret_manager_secret.editor_db.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${each.value}"
}

resource "google_secret_manager_secret_iam_member" "accounts_db" {
  for_each = {
    "account-api" = google_service_account.accounts_api.email
  }

  project   = google_secret_manager_secret.accounts_db.project
  secret_id = google_secret_manager_secret.accounts_db.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${each.value}"
}

resource "google_secret_manager_secret_iam_member" "flow_db" {
  for_each = {
    "flow-api"        = google_service_account.plateau_flow_api.email
    "flow-subscriber" = google_service_account.plateau_flow_subscriber.email
  }

  project   = google_secret_manager_secret.flow_db.project
  secret_id = google_secret_manager_secret.flow_db.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${each.value}"
}

resource "google_secret_manager_secret_iam_member" "plateau_flow_redis_url" {
  for_each = {
    "plateau-flow-api"        = google_service_account.plateau_flow_api.email
    "plateau-flow-subscriber" = google_service_account.plateau_flow_subscriber.email
    "plateau-flow-websocket"  = google_service_account.plateau_flow_websocket.email
  }

  project   = google_secret_manager_secret.plateau_flow_redis_url.project
  secret_id = google_secret_manager_secret.plateau_flow_redis_url.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${each.value}"
}
