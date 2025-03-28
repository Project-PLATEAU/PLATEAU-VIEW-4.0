resource "google_project_iam_member" "reearth_flow_websocket" {
  for_each = toset([
    "roles/cloudprofiler.agent",
    "roles/storage.objectAdmin", # TODO: Should be only granted to the bucket.
  ])

  project = data.google_project.project.project_id
  role    = each.value
  member  = "serviceAccount:${var.service_account_email}"
}
