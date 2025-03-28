module "plateau_flow_subscriber" {
  source = "./modules/plateau_flow_subscriber"

  database_secret_id        = google_secret_manager_secret.flow_db.secret_id
  domain                    = local.flow_domain
  edge_pass_subscription_id = google_pubsub_subscription.plateau_flow_edge_pass_through_main.name
  gcs_bucket_name           = google_storage_bucket.plateau_flow_bucket.name
  image                     = "reearth/reearth-flow-subscriber:nightly"
  log_subscription_id       = google_pubsub_subscription.plateau_flow_log_stream_main.name
  project                   = data.google_project.project.project_id
  redis_url_secret_id       = google_secret_manager_secret.plateau_flow_redis_url.secret_id
  region                    = var.gcp_region
  service_account_email     = google_service_account.plateau_flow_subscriber.email
}
