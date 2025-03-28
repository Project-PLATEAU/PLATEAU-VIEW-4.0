module "plateau_flow_api" {
  source = "./modules/plateau_flow_api"

  accounts_api_domain = local.accounts_api_domain

  auth0_audience                = "https://${local.flow_api_domain}"
  auth0_client_id               = module.auth0_flow.client_spa.client_id
  auth0_client_secret_secret_id = google_secret_manager_secret.flow_auth0_client_secret.secret_id
  auth0_domain                  = local.auth0_domain

  database_secret_id = google_secret_manager_secret.flow_db.secret_id
  domain             = local.flow_domain
  gcs_bucket_name    = google_storage_bucket.plateau_flow_bucket.name
  image              = "reearth/reearth-flow-api:nightly"
  origins = [
    "http://localhost:3000",
    "https://${local.flow_domain}",
    "https://*.netlify.app",
  ]
  project                 = data.google_project.project.project_id
  redis_url_secret_id     = google_secret_manager_secret.plateau_flow_redis_url.secret_id
  region                  = var.gcp_region
  service_account_email   = google_service_account.plateau_flow_api.email
  signup_secret_secret_id = google_secret_manager_secret.flow_auth0_signup_secret.secret_id

  websocket_thrift_server_url = "https://${local.flow_websocket_domain}"

  worker_allowed_locations                    = ["regions/${var.gcp_region}"]
  worker_binary_path                          = "plateau-flow-worker"
  worker_batch_sa_email                       = google_service_account.plateau_flow_worker_batch.email
  worker_image_url                            = "reearth/reearth-flow-worker:nightly"
  worker_pubsub_edge_pass_through_event_topic = google_pubsub_topic.plateau_flow_edge_pass_through.name
  worker_pubsub_job_complete_topic            = google_pubsub_topic.plateau_flow_job_complete.name
  worker_pubsub_log_stream_topic              = google_pubsub_topic.plateau_flow_log_stream.name
}
