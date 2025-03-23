import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.db.session import SessionLocal, engine
from app.db.models import Base

# Fixture to initialize and clean up the database
@pytest.fixture(scope="module")
def test_db():
    # Create all tables
    Base.metadata.create_all(bind=engine)
    yield
    # Drop all tables
    Base.metadata.drop_all(bind=engine)

# Fixture to provide a test client
@pytest.fixture(scope="module")
def client():
    with TestClient(app) as client:
        yield client