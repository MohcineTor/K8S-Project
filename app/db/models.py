from sqlalchemy.orm import declarative_base
from sqlalchemy import Column, Integer, String
# from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class Data(Base):
    __tablename__ = "data"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    value = Column(String)