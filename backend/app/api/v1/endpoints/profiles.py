from fastapi import APIRouter, HTTPException, Request
from app.schemas.profile import UserProfile, UserProfileUpdate
from app.services.profile_service import ProfileService
from app.api.v1.endpoints.events import get_current_user_id

router = APIRouter()

@router.get("/", response_model=UserProfile)
async def read_profile(request: Request):
    """
    Get current user profile preferences.
    """
    try:
        user_id = get_current_user_id(request.headers.get("Authorization"))
        profile = ProfileService.get_profile(user_id)
        if not profile:
            raise HTTPException(status_code=404, detail="Profile not found")
        return profile
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.patch("/", response_model=UserProfile)
async def update_profile(request: Request, profile_in: UserProfileUpdate):
    """
    Update user profile preferences.
    """
    try:
        user_id = get_current_user_id(request.headers.get("Authorization"))
        return ProfileService.update_profile(user_id, profile_in)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
