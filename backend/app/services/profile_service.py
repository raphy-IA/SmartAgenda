from app.core.database import db
from app.schemas.profile import UserProfileUpdate, UserProfile
from typing import Optional

class ProfileService:
    @staticmethod
    def get_profile(user_id: str) -> Optional[dict]:
        try:
            response = db.table("user_profiles").select("*").eq("user_id", user_id).execute()
            if response.data and len(response.data) > 0:
                return response.data[0]
            
            # Auto-create if not exists
            return ProfileService.create_default_profile(user_id)
        except Exception as e:
            print(f"❌ Profile Fetch Error: {e}")
            return None

    @staticmethod
    def create_default_profile(user_id: str) -> dict:
        default_profile = {
            "user_id": user_id,
            "chronotype": "neutre",
            "freeze_mode": False,
            "work_capacity_limit": 10
        }
        try:
            response = db.table("user_profiles").insert(default_profile).execute()
            return response.data[0] if response.data else default_profile
        except Exception as e:
            print(f"❌ Profile Creation Error: {e}")
            return default_profile

    @staticmethod
    def update_profile(user_id: str, profile_in: UserProfileUpdate) -> dict:
        update_data = profile_in.model_dump(exclude_unset=True)
        try:
            response = db.table("user_profiles").update(update_data).eq("user_id", user_id).execute()
            if response.data and len(response.data) > 0:
                return response.data[0]
            return update_data
        except Exception as e:
            print(f"❌ Profile Update Error: {e}")
            raise e
