module "plateau_flow_websocket" {
  source = "./modules/plateau_flow_websocket"

  gcs_bucket_name = google_storage_bucket.plateau_flow_websocket_bucket.name
  image           = "reearth/reearth-flow-websocket:nightly"
  origins = [
    "http://localhost:3000",
    "https://${local.flow_domain}",
    "https://*.netlify.app"
  ]
  project               = data.google_project.project.project_id
  redis_url_secret_id   = google_secret_manager_secret.plateau_flow_redis_url.secret_id
  region                = var.gcp_region
  service_account_email = google_service_account.plateau_flow_websocket.email
  thrift_auth_url       = "https://${local.flow_api_domain}"
}
