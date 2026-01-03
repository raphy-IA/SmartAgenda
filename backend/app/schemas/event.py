from datetime import datetime
from typing import Optional, Any
from uuid import UUID
from pydantic import BaseModel, Field

class EventBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    start_time: datetime
    end_time: datetime
    location: Optional[str] = None
    category_id: Optional[UUID] = None
    status: str = Field(default="confirmed", pattern="^(confirmed|cancelled|tentative)$")
    metadata: Optional[dict[str, Any]] = {}

class EventCreate(EventBase):
    pass

class EventUpdate(BaseModel):
    title: Optional[str] = None
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    location: Optional[str] = None
    status: Optional[str] = None
    metadata: Optional[dict[str, Any]] = None

class Event(EventBase):
    id: UUID
    user_id: UUID
    ai_generated: bool
    created_at: datetime
    
    class Config:
        from_attributes = True
