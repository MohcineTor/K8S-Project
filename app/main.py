from fastapi import FastAPI
from app.api.endpoints import data, auth
from app.core.config import settings

# Create the FastAPI app
app = FastAPI(title="My Python API")

# Include routers
app.include_router(data.router, prefix="/data", tags=["data"])
app.include_router(auth.router, prefix="/auth", tags=["auth"])

# Root endpoint
@app.get("/")
def read_root():
    return {"message": "Welcome to My Python API!"}