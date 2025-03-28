resource "google_pubsub_subscription" "plateau_flow_edge_pass_through_main" {
  project = data.google_project.project.project_id
  name    = "flow-edge-pass-through-main"
  topic   = google_pubsub_topic.plateau_flow_edge_pass_through.name

  ack_deadline_seconds       = 20
  enable_message_ordering    = false
  message_retention_duration = "604800s"

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.plateau_flow_edge_pass_through_dead_letter.id
    max_delivery_attempts = 5
  }

  expiration_policy {
    ttl = "2592000s"
  }

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }
}

resource "google_pubsub_subscription" "plateau_flow_job_complete_main" {
  project = data.google_project.project.project_id
  name    = "flow-job-complete-main"
  topic   = google_pubsub_topic.plateau_flow_job_complete.name

  ack_deadline_seconds       = 20
  enable_message_ordering    = false
  message_retention_duration = "604800s"

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.plateau_flow_job_complete_dead_letter.id
    max_delivery_attempts = 5
  }

  expiration_policy {
    ttl = "2592000s"
  }

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }
}

resource "google_pubsub_subscription" "plateau_flow_log_stream_main" {
  project = data.google_project.project.project_id
  name    = "flow-log-stream-main"
  topic   = google_pubsub_topic.plateau_flow_log_stream.name

  ack_deadline_seconds       = 20
  enable_message_ordering    = false
  message_retention_duration = "604800s"

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.plateau_flow_log_stream_dead_letter.id
    max_delivery_attempts = 5
  }

  expiration_policy {
    ttl = "2592000s"
  }

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }
}
