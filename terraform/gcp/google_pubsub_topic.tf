resource "google_pubsub_topic" "plateau_flow_edge_pass_through" {
  project = data.google_project.project.project_id
  name    = "flow-edge-pass-through"

  labels = {
    purpose = "flow-edge-status"
  }
}

resource "google_pubsub_topic" "plateau_flow_edge_pass_through_dead_letter" {
  project = data.google_project.project.project_id
  name    = "flow-edge-pass-through-dead-letter"

  labels = {
    purpose = "flow-edge-status-dead-letter"
  }
}

resource "google_pubsub_topic" "plateau_flow_job_complete" {
  project = data.google_project.project.project_id
  name    = "flow-job-complete"

  labels = {
    purpose = "flow-job-satus"
  }
}

resource "google_pubsub_topic" "plateau_flow_job_complete_dead_letter" {
  project = data.google_project.project.project_id
  name    = "flow-job-complete-dead-letter"

  labels = {
    purpose = "flow-job-status-dead-letter"
  }
}

resource "google_pubsub_topic" "plateau_flow_log_stream" {
  project = data.google_project.project.project_id
  name    = "flow-log-stream"

  labels = {
    purpose = "flow-logging"
  }
}

resource "google_pubsub_topic" "plateau_flow_log_stream_dead_letter" {
  project = data.google_project.project.project_id
  name    = "flow-log-stream-dead-letter"

  labels = {
    purpose = "flow-logging-dead-letter"
  }
}
