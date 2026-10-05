from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock

from app.main import app


client = TestClient(app)


def test_get_books():
    mock_cursor = MagicMock()
    mock_cursor.fetchall.return_value = [
        (1, "Erha", "Meatbun", "available")
    ]
    mock_connection = MagicMock()
    mock_connection.cursor.return_value = mock_cursor
    with patch("app.main.get_connection", return_value=mock_connection):
        response = client.get("/books")
    assert response.status_code == 200
    assert response.json() == [
        [1, "Erha", "Meatbun", "available"]
    ]


def test_get_users():
    mock_cursor = MagicMock()
    mock_cursor.fetchall.return_value = [
        (1, "astral")
    ]

    mock_connection = MagicMock()
    mock_connection.cursor.return_value = mock_cursor

    with patch("app.main.get_connection", return_value=mock_connection):
        response = client.get("/users")

    assert response.status_code == 200
    assert response.json() == [[1, "astral"]]


def test_create_book():
    mock_cursor = MagicMock()
    mock_connection = MagicMock()
    mock_connection.cursor.return_value = mock_cursor

    with patch("app.main.get_connection", return_value=mock_connection):
        response = client.post(
            "/books/",
            json={
                "title": "SVSSS",
                "author": "MXTX"
            }
        )

    assert response.status_code == 200
    assert response.json() == {
        "message": "Book created successfully"
    }


def test_create_user():
    mock_cursor = MagicMock()
    mock_connection = MagicMock()
    mock_connection.cursor.return_value = mock_cursor

    with patch("app.main.get_connection", return_value=mock_connection):
        response = client.post(
            "/users/",
            json={
                "username": "astral"
            }
        )

    assert response.status_code == 200
    assert response.json() == {
        "message": "User created successfully"
    }


def test_return_book():
    mock_cursor = MagicMock()
    mock_connection = MagicMock()
    mock_connection.cursor.return_value = mock_cursor

    with patch("app.main.get_connection", return_value=mock_connection):
        response = client.delete("/borrowings/1")

    assert response.status_code == 200
    assert response.json() == {
        "message": "Book returned successfully"
    }