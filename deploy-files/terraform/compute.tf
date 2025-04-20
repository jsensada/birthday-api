resource "google_compute_instance_template" "birthday_api_servers" {
  name_prefix = "birthday-api-"
  machine_type = var.machine_type
  tags = ["birthday-api"]

  metadata_startup_script = <<-EOT
    #!/bin/bash
    cat <<EOF > /opt/birthday-api/.env
    DB_HOST=google_sql_database_instance.brithday_db.connection_name
    DB_USER=data.google_secret_manager_secret_version.birthday_db_username.secret_data
    DB_PASS=data.google_secret_manager_secret_version.birthday_db_password.secret_data
    EOF
  EOT

  disk {
    source_image = var.image_name
    auto_delete  = true
    boot         = true
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance_group_manager" "birthday_api_servers_pool" {
  name               = "birthday-api-pool"
  zone               = "${var.region}-a"
  base_instance_name = "birthday-api"
  target_size        = var.instance_pool_size
  version {
    instance_template = google_compute_instance_template.birthday_api_servers.id
  }
}

resource "google_compute_health_check" "birthday_api_hc" {
  name               = "birthday-api-health-check"
  check_interval_sec = 5
  timeout_sec        = 5
  healthy_threshold  = 2
  unhealthy_threshold = 2

  http_health_check {
    port = 5000
    request_path = "/health"
  }
}

resource "google_compute_backend_service" "birthday_api_backend" {
  name                  = "birthday-api-backend"
  load_balancing_scheme = "EXTERNAL"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 10
  health_checks         = [google_compute_health_check.birthday_api_hc.id]

  backend {
    group = google_compute_instance_group_manager.birthday_api_servers_pool.instance_group
  }
}

resource "google_compute_url_map" "birthday_api_map" {
  name            = "birthday-api-map"
  default_service = google_compute_backend_service.birthday_api_backend.id
}

resource "google_compute_target_http_proxy" "birthday_api_proxy" {
  name    = "birthday-api-http-proxy"
  url_map = google_compute_url_map.birthday_api_map.id
}

resource "google_compute_global_forwarding_rule" "birthday_api_forwarding_rule" {
  name       = "birthday-api-http-rule"
  target     = google_compute_target_http_proxy.birthday_api_proxy.id
  port_range = "5000"
}