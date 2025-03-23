from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from app.core.security import create_access_token
from app.core.config import settings
import os
import hvac
import logging

router = APIRouter()

# Logging setup
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Vault configuration
VAULT_ADDR = os.getenv("VAULT_ADDR")
VAULT_ROLE = os.getenv("VAULT_ROLE")

def get_vault_client():
    """Authenticate with Vault using Kubernetes service account token."""
    try:
        logger.info("Initializing Vault client...")
        with open("/var/run/secrets/kubernetes.io/serviceaccount/token", "r") as f:
            jwt = f.read()
        logger.info(f"Connecting to Vault at {VAULT_ADDR} with role {VAULT_ROLE}...")
        client = hvac.Client(url=VAULT_ADDR)
        response = client.auth.kubernetes.login(role=VAULT_ROLE, jwt=jwt)
        return client
    except Exception as e:
        logger.error(f"Vault authentication failed: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Vault authentication failed: {str(e)}")
def get_vault_secrets():
    """Retrieve secrets from Vault."""
    client = get_vault_client()
    try:
        secret_path = "data/auth"
        secrets = client.secrets.kv.v2.read_secret_version(path=secret_path, mount_point="secret")
        logger.info("Vault secrets retrieved successfully.")
        return secrets["data"]["data"]
    except Exception as e:
        logger.error(f"Failed to fetch secrets: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch secrets: {str(e)}")

@router.post("/token")
def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends()):

    # Fetch secrets from Vault
    secrets = get_vault_secrets()
    vault_user = secrets["testuser"]
    vault_pass = secrets["testpass"]
    # Mock user authentication
    if form_data.username != vault_user or form_data.password != vault_pass:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
        )
    # Create a token
    access_token = create_access_token(data={"sub": form_data.username})
    return {"access_token": access_token, "token_type": "bearer"}