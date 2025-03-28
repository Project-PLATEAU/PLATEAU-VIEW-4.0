resource "google_service_networking_connection" "default" {
  provider = google-beta

  network = data.google_compute_network.default.id
  reserved_peering_ranges = [
    google_compute_global_address.cms_cloudbuild.name,
    google_compute_global_address.plateau_flow_subscriber.name,
    google_compute_global_address.plateau_flow_websocket.name,
  ]
  service = "servicenetworking.googleapis.com"
}
