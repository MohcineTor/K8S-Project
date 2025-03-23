from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from app.core.config import settings
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.db.models import Data
from app.schemas.data import DataCreate, DataResponse
import logging

logger = logging.getLogger(__name__)
router = APIRouter()



oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/token")

def get_current_user(token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    return username

@router.post("/", response_model=DataResponse)
def create_data(data: DataCreate, db: Session = Depends(get_db), current_user: str = Depends(get_current_user)):
    db_data = Data(name=data.name, value=data.value)
    db.add(db_data)
    db.commit()
    db.refresh(db_data)
    logger.info(f"Created data: {db_data.__dict__}")
    return {
        "id": db_data.id,
        "name": db_data.name,
        "value": db_data.value
    }

@router.get("/{data_id}", response_model=DataResponse)
def read_data(data_id: int, db: Session = Depends(get_db), current_user: str = Depends(get_current_user)):
    db_data = db.query(Data).filter(Data.id == data_id).first()
    if db_data is None:
        raise HTTPException(status_code=404, detail="Data not found")
    return {
        "id": db_data.id,
        "name": db_data.name,
        "value": db_data.value
    }


@router.delete("/{data_id}")
def delete_data(data_id: int, db: Session = Depends(get_db)):
    db_data = db.query(Data).filter(Data.id == data_id).first()
    if db_data is None:
        raise HTTPException(status_code=404, detail="Data not found")
    db.delete(db_data)
    db.commit()
    return {"message": "Data deleted"}