from datetime import datetime
from uuid import UUID
from typing import Optional
from pydantic import BaseModel, EmailStr

class UserBase(BaseModel):
    email: EmailStr
    full_name: Optional[str] = None
    preferences: Optional[dict] = {}

class UserCreate(UserBase):
    pass

class User(UserBase):
    id: UUID
    created_at: datetime
    frozen_until: Optional[datetime] = None

    class Config:
        from_attributes = True
