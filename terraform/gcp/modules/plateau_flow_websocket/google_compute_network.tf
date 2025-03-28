data "google_compute_network" "default" {
  project = data.google_project.project.project_id
  name    = "default"
}
