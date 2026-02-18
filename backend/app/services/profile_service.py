from app.core.database import db
from app.schemas.profile import UserProfileUpdate, UserProfile
from typing import Optional

class ProfileService:
    @staticmethod
    def get_profile(user_id: str) -> dict:
        try:
            response = db.table("user_profiles").select("*").eq("user_id", user_id).execute()
            if response.data and len(response.data) > 0:
                return response.data[0]
            
            return ProfileService.create_default_profile(user_id)
        except Exception as e:
            print(f"❌ Profile Fetch Error (Table likely missing): {e}")
            return ProfileService.create_default_profile(user_id)

    @staticmethod
    def create_default_profile(user_id: str) -> dict:
        from datetime import datetime, timezone
        now = datetime.now(timezone.utc)
        default_profile = {
            "user_id": user_id,
            "chronotype": "neutre",
            "freeze_mode": False,
            "work_capacity_limit": 10,
            "created_at": now.isoformat(),
            "updated_at": now.isoformat()
        }
        try:
            response = db.table("user_profiles").insert(default_profile).execute()
            if response.data:
                return response.data[0]
            return default_profile
        except Exception as e:
            print(f"⚠️ Profile Creation skipped (Table missing): {e}")
            return default_profile

    @staticmethod
    def update_profile(user_id: str, profile_in: UserProfileUpdate) -> dict:
        update_data = profile_in.model_dump(exclude_unset=True)
        try:
            response = db.table("user_profiles").update(update_data).eq("user_id", user_id).execute()
            if response.data and len(response.data) > 0:
                return response.data[0]
            
            # If no data returned but no error, return merged mock
            current = ProfileService.get_profile(user_id)
            current.update(update_data)
            return current
        except Exception as e:
            print(f"⚠️ Profile Update redirected to MOCK: {e}")
            current = ProfileService.get_profile(user_id)
            current.update(update_data)
            return current
