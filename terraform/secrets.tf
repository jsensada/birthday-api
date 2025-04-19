data "google_secret_manager_secret_version" "birthday_db_username" {
  provider = google
  secret   = "brithday-db-username"
  project  = "birthday-api-20250419"
}

data "google_secret_manager_secret_version" "birthday_db_password" {
  provider = google
  secret   = "brithday-db-password"
  project  = "birthday-api-20250419"
}