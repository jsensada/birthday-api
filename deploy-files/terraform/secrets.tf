data "google_secret_manager_secret_version" "birthday_db_username" {
  provider = google
  secret   = "brithday-db-username"
  project  = var.project_id
}

data "google_secret_manager_secret_version" "birthday_db_password" {
  provider = google
  secret   = "brithday-db-password"
  project  = var.project_id
}