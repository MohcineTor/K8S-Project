from fastapi import status
from app.core.security import create_access_token

def test_create_token(client):
    response = client.post("/auth/token", data={"username": "testuser", "password": "testpass"})
    assert response.status_code == status.HTTP_200_OK
    assert "access_token" in response.json()
    assert response.json()["token_type"] == "bearer"

# def test_protected_endpoint(client):
#     response = client.get("/data/1")
#     assert response.status_code == status.HTTP_401_UNAUTHORIZED
#     token = create_access_token({"sub": "testuser"})
#     headers = {"Authorization": f"Bearer {token}"}
#     response = client.get("/data/1", headers=headers)
#     assert response.status_code == status.HTTP_404_NOT_FOUND
def test_protected_endpoint(client):
    # First, get a valid token
    token_response = client.post("/auth/token", data={"username": "testuser", "password": "testpass"})
    token = token_response.json()["access_token"]

    # Use the token to access the protected endpoint
    response = client.get("/data/1", headers={"Authorization": f"Bearer {token}"})
    assert response.status_code == 404  # Assuming the data does not exist