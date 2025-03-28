resource "google_project_iam_member" "reearth_flow_api" {
  for_each = toset([
    "roles/batch.jobsEditor",
    "roles/cloudprofiler.agent",
    "roles/iam.serviceAccountUser",
    "roles/storage.objectAdmin",
  ])

  project = data.google_project.project.project_id
  role    = each.value
  member  = "serviceAccount:${var.service_account_email}"
}
