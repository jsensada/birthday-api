import logging, re
import mysql.connector
from flask import Flask, request, jsonify, abort
from db.config import dbconfig
from datetime import datetime, date

pool_name = "mysql_pool"
cnxpool = mysql.connector.pooling.MySQLConnectionPool(pool_name = pool_name,
                                                      pool_size = 5,
                                                      **dbconfig)

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
    
def get_days_until_next_birthday(dob: date) -> int:
    today = date.today()
    next_birthday = dob.replace(year=today.year)
    if next_birthday < today:
        next_birthday = next_birthday.replace(year=today.year + 1)
    return (next_birthday - today).days
    

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


    days_until_birthday = get_days_until_next_birthday(result[0])
    app.logger.info('Days until birthday: %s', days_until_birthday)

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
        abort(400, description='[ERROR]: username must contain only letters.')

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
    app.logger.info('Starting Flask application...')
    app.run(debug=True, host='0.0.0.0')