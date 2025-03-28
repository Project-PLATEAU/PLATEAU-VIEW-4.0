resource "google_redis_instance" "plateau_flow" {
  project = data.google_project.project.project_id
  name    = "plateau-flow"

  auth_enabled       = true
  authorized_network = data.google_compute_network.default.id
  connect_mode       = "PRIVATE_SERVICE_ACCESS"
  memory_size_gb     = 4
  replica_count      = 1
  redis_version      = "REDIS_7_2"
  redis_configs = {
    "maxmemory-policy"       = "allkeys-lru"
    "notify-keyspace-events" = "Ex" // Enable keyspace events
    "timeout"                = "300"
  }
  region = "asia-northeast1"
  tier   = "STANDARD_HA"

  persistence_config {
    persistence_mode    = "RDB"
    rdb_snapshot_period = "ONE_HOUR"
  }
}
