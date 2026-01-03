from uuid import UUID
from typing import Optional
from pydantic import BaseModel

class CategoryBase(BaseModel):
    name: str
    color_hex: str
    priority_level: int
    is_default: bool = False

class CategoryCreate(CategoryBase):
    pass

class Category(CategoryBase):
    id: UUID

    class Config:
        from_attributes = True
