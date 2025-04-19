resource "google_sql_database_instance" "brithday_db" {
  name = "birthday-db"
  deletion_protection = false
  database_version = "MYSQL_8_4"
  region = "europe-southwest1"
  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_user" "birthday_user" {
  name = data.google_secret_manager_secret_version.birthday_db_username.secret_data
  password = data.google_secret_manager_secret_version.birthday_db_password.secret_data
  instance = google_sql_database_instance.brithday_db.name
}