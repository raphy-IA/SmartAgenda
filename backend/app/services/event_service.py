from uuid import uuid4
from typing import List
from app.core.database import db
from app.schemas.event import EventCreate, EventUpdate, Event

# Mock Storage (In-Memory) pour le développement si Supabase n'est pas configuré
MOCK_DB_STORE = []

class EventService:
    @staticmethod
    def _is_mock_mode():
        """Détecte si Supabase est mal configuré et bascule en mock."""
        try:
            # Test simple : si db est None (probablement pas le cas car init au démarrage)
            # ou si URL vide (plus probable)
            from app.core.config import settings
            return not settings.SUPABASE_URL or not settings.SUPABASE_KEY
        except:
            return True

    @staticmethod
    def get_user_events(user_id: str) -> List[dict]:
        if EventService._is_mock_mode():
            print(f"[EventService] MOCK MODE: Filtering events for user {user_id}")
            return [e for e in MOCK_DB_STORE if e.get("user_id") == user_id]
            
        try:
            response = db.table("events").select("*").eq("user_id", user_id).execute()
            return response.data
        except Exception as e:
            print(f"❌ DB ERROR: {e}. Falling back to MOCK.")
            return [e for e in MOCK_DB_STORE if e.get("user_id") == user_id]

    @staticmethod
    def create_event(user_id: str, event_in: EventCreate) -> dict:
        event_dict = event_in.model_dump()
        event_dict["user_id"] = user_id
        
        # Génération ID si pas présent
        if "id" not in event_dict or not event_dict["id"]:
            event_dict["id"] = str(uuid4())

        # Conversion dates en ISO string (UTC Explicit)
        from datetime import timezone
        if hasattr(event_dict["start_time"], "astimezone"):
            event_dict["start_time"] = event_dict["start_time"].astimezone(timezone.utc).isoformat()
        if hasattr(event_dict["end_time"], "astimezone"):
            event_dict["end_time"] = event_dict["end_time"].astimezone(timezone.utc).isoformat()

        if EventService._is_mock_mode():
            print(f"[EventService] MOCK MODE: Creating event {event_dict['title']}")
            MOCK_DB_STORE.append(event_dict)
            return event_dict

        try:
            # --- DYNAMIC CATEGORY LOGIC ---
            meta = event_dict.get("metadata", {})
            suggested_cat_name = meta.get("suggested_category")
            
            if suggested_cat_name:
                print(f"[EventService] AI Suggested Category: '{suggested_cat_name}'. Checking existence...")
                # 1. Search existing (Case Insensitive)
                # Note: ilike is better but Supabase-py uses .ilike() or just .eq() if text is exact.
                # Let's try flexible search.
                try:
                    cat_res = db.table("categories").select("id").ilike("name", suggested_cat_name).execute()
                    
                    category_id = None
                    if cat_res.data and len(cat_res.data) > 0:
                        category_id = cat_res.data[0]["id"]
                        print(f"[EventService] Matched existing category ID: {category_id}")
                    else:
                        # 2. Create if missing
                        print(f"[EventService] Category '{suggested_cat_name}' not found. Creating new...")
                        from app.utils.color_utils import generate_color_from_text
                        
                        new_cat = {
                            "name": suggested_cat_name,
                            "color_hex": generate_color_from_text(suggested_cat_name),
                            "priority_level": 5, # Default
                            "is_default": False
                        }
                        
                        cat_insert = db.table("categories").insert(new_cat).execute()
                        if cat_insert.data:
                            category_id = cat_insert.data[0]["id"]
                            print(f"[EventService] Created new category ID: {category_id} (Color: {new_cat['color_hex']})")
                    
                    if category_id:
                        event_dict["category_id"] = category_id
                        
                except Exception as cat_e:
                    print(f"⚠️ [EventService] Failed to process dynamic category: {cat_e} (Proceeding without category_id)")

            # --- INSERT EVENT ---
            print(f"[EventService] Inserting event: {event_dict}")
            response = db.table("events").insert(event_dict).execute()
            print(f"[EventService] Supabase Response: {response}")
            
            if response.data and len(response.data) > 0:
                print(f"[EventService] Success Data: {response.data[0]}")
                return response.data[0]
            else:
                print("⚠️ [EventService] Warning: Insertion successful but no data returned.")
                # On retourne les données envoyées si pas de retour serveur (pour éviter crash)
                return event_dict
        except Exception as e:
            print(f"❌ DB ERROR: {e}. Falling back to MOCK.")
            MOCK_DB_STORE.append(event_dict)
            return event_dict

    @staticmethod
    def update_event(user_id: str, event_id: str, event_in: EventUpdate) -> dict:
        event_data = event_in.model_dump(exclude_unset=True)
        
        # Conversion dates
        if "start_time" in event_data and hasattr(event_data["start_time"], "isoformat"):
            event_data["start_time"] = event_data["start_time"].isoformat()
        if "end_time" in event_data and hasattr(event_data["end_time"], "isoformat"):
            event_data["end_time"] = event_data["end_time"].isoformat()

        if EventService._is_mock_mode():
            print(f"[EventService] MOCK MODE: Updating event {event_id}")
            for i, ev in enumerate(MOCK_DB_STORE):
                if ev["id"] == event_id and ev["user_id"] == user_id:
                    MOCK_DB_STORE[i].update(event_data)
                    return MOCK_DB_STORE[i]
            raise ValueError("Event not found (Mock)")

        try:
            response = db.table("events").update(event_data).eq("id", event_id).eq("user_id", user_id).execute()
            return response.data[0]
        except Exception as e:
            print(f"❌ DB ERROR: {e}. Falling back to MOCK.")
            # Tentative de mise à jour dans le mock si la DB échoue
            for i, ev in enumerate(MOCK_DB_STORE):
                if ev["id"] == event_id and ev["user_id"] == user_id:
                    MOCK_DB_STORE[i].update(event_data)
                    return MOCK_DB_STORE[i]
            raise e

    @staticmethod
    def delete_event(user_id: str, event_id: str):
        if EventService._is_mock_mode():
            print(f"[EventService] MOCK MODE: Deleting event {event_id}")
            # Suppression in-place pour éviter "global" keyword error
            MOCK_DB_STORE[:] = [e for e in MOCK_DB_STORE if not (e["id"] == event_id and e["user_id"] == user_id)]
            return

        try:
            db.table("events").delete().eq("id", event_id).eq("user_id", user_id).execute()
        except Exception as e:
            print(f"❌ DB ERROR: {e}. Falling back to MOCK.")
            MOCK_DB_STORE[:] = [e for e in MOCK_DB_STORE if not (e["id"] == event_id and e["user_id"] == user_id)]

