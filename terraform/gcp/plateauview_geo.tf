module "plateauview_geo" {
  source = "./modules/plateauview_geo"

  domain                 = var.domain
  dns_managed_zone_name  = google_dns_managed_zone.zone.name
  gcp_project_id         = data.google_project.project.project_id
  gcp_region             = var.gcp_region
  prefix                 = var.prefix
  tile_cache_bucket_name = google_storage_bucket.app_tile_cache.name
  service_account_email  = google_service_account.plateauview_geo.email
}
