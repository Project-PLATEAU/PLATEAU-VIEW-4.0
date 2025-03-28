resource "google_project_iam_member" "reearth_flow_web" {
  for_each = toset([
    "roles/cloudprofiler.agent",
  ])

  project = data.google_project.project.project_id
  role    = each.value
  member  = "serviceAccount:${var.service_account_email}"
}
