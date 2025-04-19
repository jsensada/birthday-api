import pytest
from app import app

@pytest.fixture
def client():
    app.testing = True
    with app.test_client() as client:
        yield client


def test_health(client):
    response = client.get('/health')
    assert response.status_code == 200
    assert b"[OK]" in response.data

def test_hello_get_birthday(client):
    # Test with a valid username
    response = client.get('/hello/foo')
    assert b"Hello, foo!" in response.data
    assert response.status_code == 200

    # Test with an invalid username
    response = client.get('/hello/invalid_username!')
    assert response.status_code == 400
    assert b"Invalid username." in response.data

    # Test with a non-existent user
    response = client.get('/hello/nonexistentuser')
    assert response.status_code == 404
    assert b"User not found." in response.data