from supabase import create_client, Client
from app.core.config import settings

class SupabaseService:
    _instance = None
    client: Client = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(SupabaseService, cls).__new__(cls)
            cls._instance.client = create_client(settings.SUPABASE_URL, settings.SUPABASE_KEY)
        return cls._instance

# Instance globale
db = SupabaseService().client
