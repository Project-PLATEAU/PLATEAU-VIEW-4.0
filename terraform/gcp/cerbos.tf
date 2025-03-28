module "cerbos" {
  source = "./modules/cerbos"

  image                 = "cerbos/cerbos:0.40.0"
  policy_bucket         = google_storage_bucket.cerbos_policy.name
  project               = data.google_project.project.project_id
  region                = var.gcp_region
  service_account_email = google_service_account.cerbos.email

  depends_on = [
    google_storage_bucket_iam_member.cerbos_is_cerbos_policy_object_admin,
  ]
}
