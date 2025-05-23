resource "google_sql_database_instance" "birthday_db" {
  name                = "birthday-db"
  deletion_protection = false
  database_version    = "MYSQL_8_4"
  region              = var.region
  settings {
    tier    = "db-custom-2-8192"
    edition = "ENTERPRISE"
    # Using public IP to simplify the exercise
  }
}

resource "google_sql_database" "birthday_db_schema" {
  name     = "birthday"
  instance = google_sql_database_instance.birthday_db.name
  charset  = "utf8mb4"
}

resource "google_sql_user" "birthday_user" {
  name     = data.google_secret_manager_secret_version.birthday_db_username.secret_data
  password = data.google_secret_manager_secret_version.birthday_db_password.secret_data
  instance = google_sql_database_instance.birthday_db.name
}

resource "null_resource" "init_db_schema" {
  depends_on = [google_sql_database.birthday_db_schema]

  provisioner "local-exec" {
    command = <<EOT
      mysql -h ${google_sql_database_instance.birthday_db.public_ip_address} \
            -u ${data.google_secret_manager_secret_version.birthday_db_username.secret_data} \
            -p${data.google_secret_manager_secret_version.birthday_db_password.secret_data} \
            -D birthdays \
            -e "CREATE TABLE IF NOT EXISTS users (username VARCHAR(50) PRIMARY KEY,date_of_birth DATE NOT NULL);"
    EOT
  }
}
