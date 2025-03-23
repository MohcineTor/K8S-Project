from fastapi import status

def test_create_data(client):
    # First, get a valid token
    token_response = client.post("/auth/token", data={"username": "testuser", "password": "testpass"})
    token = token_response.json()["access_token"]

    # Use the token to create data
    response = client.post(
        "/data",
        json={"name": "test", "value": "123"},
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 200
    assert response.json()["name"] == "test"
    assert response.json()["value"] == "123"

def test_read_data(client):
    # First, get a valid token
    token_response = client.post("/auth/token", data={"username": "testuser", "password": "testpass"})
    token = token_response.json()["access_token"]

    # Create data
    create_response = client.post(
        "/data",
        json={"name": "test", "value": "123"},
        headers={"Authorization": f"Bearer {token}"}
    )
    data_id = create_response.json()["id"]

    # Read data
    response = client.get(f"/data/{data_id}", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    assert response.json()["name"] == "test"
    assert response.json()["value"] == "123"

def test_delete_data(client):
    # First, get a valid token
    token_response = client.post("/auth/token", data={"username": "testuser", "password": "testpass"})
    token = token_response.json()["access_token"]

    # Create data
    create_response = client.post(
        "/data",
        json={"name": "test", "value": "123"},
        headers={"Authorization": f"Bearer {token}"}
    )
    data_id = create_response.json()["id"]

    # Delete data
    response = client.delete(f"/data/{data_id}", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 200
    assert response.json()["message"] == "Data deleted"

    # Verify data is deleted
    response = client.get(f"/data/{data_id}", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 404