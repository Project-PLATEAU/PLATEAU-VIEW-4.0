module "accounts_api" {
  source = "./modules/accounts_api"

  cerbos_host        = "${local.cerbos_domain}:443"
  database_secret_id = google_secret_manager_secret.accounts_db.secret_id
  domain             = local.accounts_domain
  image              = "reearth/reearth-accounts-api:nightly"
  origins = [
    "http://localhost:3000",
    "http://localhost:8080",
    "https://${local.accounts_domain}",
    "https://api.${local.flow_domain}",
    "https://${local.flow_api_domain}",
    "https://*.netlify.app",
  ]
  project               = data.google_project.project.project_id
  region                = var.gcp_region
  service_account_email = google_service_account.accounts_api.email
}
