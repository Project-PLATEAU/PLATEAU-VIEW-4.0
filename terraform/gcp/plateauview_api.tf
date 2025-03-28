module "plateauview_api" {
  source = "./modules/plateauview_api"

  chiitiler_bucket      = module.chiitiler.bucket
  chiitiler_url         = module.chiitiler.url
  ckan_token            = var.ckan_token
  domain                = var.domain
  fme_token             = var.fme_token
  gcp_project_id        = data.google_project.project.project_id
  gcp_region            = var.gcp_region
  plateauview           = var.plateauview
  prefix                = var.prefix
  sendgrid_api_key      = var.sendgrid_api_key
  service_account_email = google_service_account.plateauview_api.email
}
