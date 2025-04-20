data "google_secret_manager_secret_version" "birthday_db_username" {
  provider = google
  secret   = "birthday-db-username"
  project  = var.project_id
}

data "google_secret_manager_secret_version" "birthday_db_password" {
  provider = google
  secret   = "birthday-db-password"
  project  = var.project_id
}