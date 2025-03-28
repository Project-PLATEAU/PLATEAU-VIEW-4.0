module "plateau_flow_web_us_central1" {
  source = "./modules/plateau_flow_web"

  auth0_audience  = "https://${local.flow_api_domain}"
  auth0_domain    = var.auth0_domain
  auth0_client_id = module.auth0_flow.client_spa.client_id

  domain                = local.flow_domain
  image                 = "reearth/reearth-flow-web:nightly"
  project               = data.google_project.project.project_id
  region                = var.gcp_region
  service_account_email = google_service_account.plateau_flow_web.email

  brand_name        = "PLATEAU Flow"
  flow_version      = "0.0.1"
  dev_mode          = true
  gh_repo_url       = "https://github.com/reearth/reearth-flow"
  tos_url           = "https://reearth.io/docs/terms-of-service"
  documentation_url = "https://help.reearth.io/"

  websocket_url = "wss://${local.flow_websocket_domain}"
}
