from pydantic import BaseModel

class DataCreate(BaseModel):
    name: str
    value: str

class DataResponse(BaseModel):
    id: int
    name: str
    value: str