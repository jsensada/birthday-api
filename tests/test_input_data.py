import pytest
from app import app

@pytest.fixture
def client():
    app.testing = True
    with app.test_client() as client:
        yield client

def test_hello_put_birthday(client):
    # Test with a valid username and valid date
    response = client.put('/hello/foo', json={"dateOfBirth": "2000-01-01"})
    assert response.status_code == 204

    # Test with an invalid username
    response = client.put('/hello/invalid_username!', json={"dateOfBirth": "2000-01-01"})
    assert response.status_code == 400
    assert b"[ERROR]: username must contain only letters." in response.data

    # Test with a missing dateOfBirth
    response = client.put('/hello/foo', json={})
    assert response.status_code == 400
    assert b"[ERROR]: Missing dateOfBirth in request." in response.data

    # Test with an invalid date format
    response = client.put('/hello/foo', json={"dateOfBirth": "01-01-2000"})
    assert response.status_code == 400
    assert b"[ERROR] Format YYYY-MM-DD and it must be a date before the today date." in response.data

    # Test with a future date
    response = client.put('/hello/foo', json={"dateOfBirth": "3000-01-01"})
    assert response.status_code == 400
    assert b"[ERROR] Format YYYY-MM-DD and it must be a date before the today date." in response.data

def test_hello_get_birthday(client):
    # Test with a valid username
    response = client.get('/hello/foo')
    assert response.status_code == 200
    assert b"Hello, foo!" in response.data

    # Test with an invalid username
    response = client.get('/hello/invalid_username!')
    assert response.status_code == 400
    assert b"Invalid username." in response.data

    # Test with a non-existent user
    response = client.get('/hello/nonexistentuser')
    assert response.status_code == 404
    assert b"User not found." in response.data