import os

# This file is used to configure the database connection
db_host = os.getenv('DB_HOST') if os.getenv('DB_HOST') else "db"
db_port = os.getenv('DB_PORT') if os.getenv('DB_PORT') else 3306
db_name = os.getenv('DB_NAME') if os.getenv('DB_NAME') else "birthday"
db_user = os.getenv('DB_USER') if os.getenv('DB_USER') else "birthday"
db_pass = os.getenv('DB_PASS') if os.getenv('DB_PASS') else "birthday-api"


dbconfig = {
    'host': db_host,
    'port': db_port,

    'database': db_name,

    'user': db_user,
    'password': db_pass
}