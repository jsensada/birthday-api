import os, logging, re
import mysql.connector
from flask import Flask, request, jsonify, abort
from datetime import datetime, date

db_host = os.getenv('DB_HOST') if os.getenv('DB_HOST') else "NoDBname"
db_name = os.getenv('DB_NAME') if os.getenv('DB_NAME') else "NoDBname"
db_user = os.getenv('DB_USER') if os.getenv('DB_USER') else "NoDBuser"
db_pass = os.getenv('DB_PASS') if os.getenv('DB_PASS') else "NoDBpass"


dbconfig = {
    'host': db_host,
    'database': db_name,
    'user': db_user,
    'password': db_pass
}
pool_name = "mysql_pool"
cnxpool = mysql.connector.pooling.MySQLConnectionPool(pool_name = pool_name, pool_size = 5, **dbconfig)


app = Flask(__name__)
logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s %(levelname)s %(message)s',
                    handlers=[logging.StreamHandler()])
logger = logging.getLogger(__name__)


def get_db_connection():
    return cnxpool.get_connection()


def check_valid_username(username):
    return re.fullmatch(r'[a-zA-Z]+', username)


def check_valid_birthday(birthday):
    try:
        birthday_date = datetime.strptime(birthday, '%Y-%m-%d').date()
        return birthday_date < date.today()
    except ValueError:
        return False


def create_db_schema_if_not_exists():
    cnx = cnxpool.get_connection()
    cursor = cnx.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            username VARCHAR(50) PRIMARY KEY,
            date_of_birth DATE NOT NULL
        )
    """)
    cnx.commit()
    cursor.close()
    cnx.close()
    

@app.route('/health')
def health():
    app.logger.info('Health check for instance %s')
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.close()
    conn.close()
    return "[OK]", 200


@app.route('/hello/<username>', methods=['GET'])
def hello_get_birthday(username):
    if not check_valid_username(username):
        abort(400, description='Invalid username.')

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT date_of_birth FROM users WHERE username = %s", (username.lower(),))
    result = cursor.fetchone()
    cursor.close()
    conn.close()

    if not result:
        abort(404, description='User not found.')

    dob = result[0]
    today = date.today()
    next_birthday = dob.replace(year=today.year)

    if next_birthday < today:
        next_birthday = next_birthday.replace(year=today.year + 1)

    days_until_birthday = (next_birthday - today).days

    if days_until_birthday == 0:
        message = f"Hello, {username}! Happy birthday!"
    else:
        message = f"Hello, {username}! Your birthday is in {days_until_birthday} day(s)"

    return jsonify({"message": message}), 200


@app.route('/hello/<username>', methods=['PUT'])
def hello_put_birthday(username):
    app.logger.info('Processing request for username: %s', username)
    app.logger.info('Request data: %s', request.data)
    if not check_valid_username(username):
        abort(400, description='[ERROR]: <username> must contain only letters.')

    data = request.get_json()
    if not data or 'dateOfBirth' not in data:
        abort(400, description='[ERROR]: Missing dateOfBirth in request.')

    dob_str = data['dateOfBirth']
    if not check_valid_birthday(dob_str):
        abort(400, description='[ERROR] Format YYYY-MM-DD and it must be a date before the today date.')

    dob = datetime.strptime(dob_str, '%Y-%m-%d').date()

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO users (username, date_of_birth) VALUES (%s, %s)
        ON DUPLICATE KEY UPDATE date_of_birth = VALUES(date_of_birth)
    """, (username.lower(), dob))
    conn.commit()
    cursor.close()
    conn.close()

    return '', 204


if __name__ == '__main__':
    app.logger.info('Creating database schema if not exists...')
    create_db_schema_if_not_exists()
    app.logger.info('Database schema created.')
    app.logger.info('Starting Flask application...')
    app.run(debug=True, host='0.0.0.0')