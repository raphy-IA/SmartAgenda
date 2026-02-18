from pydantic import BaseModel, Field
from typing import Optional
from uuid import UUID
from datetime import datetime

class UserProfileBase(BaseModel):
    chronotype: str = Field(default="neutre", pattern="^(matin|soir|neutre)$")
    freeze_mode: bool = False
    work_capacity_limit: int = Field(default=10, ge=1, le=24)

class UserProfileUpdate(BaseModel):
    chronotype: Optional[str] = Field(None, pattern="^(matin|soir|neutre)$")
    freeze_mode: Optional[bool] = None
    work_capacity_limit: Optional[int] = Field(None, ge=1, le=24)

class UserProfile(UserProfileBase):
    user_id: UUID
    updated_at: datetime

    class Config:
        from_attributes = True
