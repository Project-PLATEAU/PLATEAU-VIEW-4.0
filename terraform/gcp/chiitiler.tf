module "chiitiler" {
  source = "./modules/chiitiler"

  image                 = "eukarya/plateauview-chiitiler:latest"
  prefix                = var.prefix
  project               = data.google_project.project.project_id
  region                = var.gcp_region
  service_account_email = google_service_account.chiitiler.email
}
