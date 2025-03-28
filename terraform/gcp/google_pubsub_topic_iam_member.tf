resource "google_pubsub_topic_iam_member" "plateau_flow_edge_pass_through_publisher" {
  project = data.google_project.project.project_id
  topic   = google_pubsub_topic.plateau_flow_edge_pass_through.name
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.plateau_flow_worker_batch.email}"
}

resource "google_pubsub_topic_iam_member" "plateau_flow_edge_pass_through_subscriber" {
  project = data.google_project.project.project_id
  topic   = google_pubsub_topic.plateau_flow_edge_pass_through.name
  role    = "roles/pubsub.subscriber"
  member  = "allUsers"
}

resource "google_pubsub_topic_iam_member" "plateau_flow_edge_pass_through_viewer" {
  project = data.google_project.project.project_id
  topic   = google_pubsub_topic.plateau_flow_edge_pass_through.name
  role    = "roles/pubsub.viewer"
  member  = "allUsers"
}

resource "google_pubsub_topic_iam_member" "plateau_flow_job_complete_publisher" {
  project = data.google_project.project.project_id
  topic   = google_pubsub_topic.plateau_flow_job_complete.name
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.plateau_flow_worker_batch.email}"
}

resource "google_pubsub_topic_iam_member" "plateau_flow_job_complete_subscriber" {
  project = data.google_project.project.project_id
  topic   = google_pubsub_topic.plateau_flow_job_complete.name
  role    = "roles/pubsub.subscriber"
  member  = "allUsers"
}

resource "google_pubsub_topic_iam_member" "plateau_flow_job_complete_viewer" {
  project = data.google_project.project.project_id
  topic   = google_pubsub_topic.plateau_flow_job_complete.name
  role    = "roles/pubsub.viewer"
  member  = "allUsers"
}

resource "google_pubsub_topic_iam_member" "plateau_flow_log_stream_publisher" {
  project = data.google_project.project.project_id
  topic   = google_pubsub_topic.plateau_flow_log_stream.name
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.plateau_flow_worker_batch.email}"
}

resource "google_pubsub_topic_iam_member" "plateau_flow_log_stream_subscriber" {
  project = data.google_project.project.project_id
  topic   = google_pubsub_topic.plateau_flow_log_stream.name
  role    = "roles/pubsub.subscriber"
  member  = "allUsers"
}

resource "google_pubsub_topic_iam_member" "plateau_flow_log_stream_viewer" {
  project = data.google_project.project.project_id
  topic   = google_pubsub_topic.plateau_flow_log_stream.name
  role    = "roles/pubsub.viewer"
  member  = "allUsers"
}
