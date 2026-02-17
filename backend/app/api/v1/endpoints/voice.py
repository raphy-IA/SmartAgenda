from typing import Dict, Any
from fastapi import APIRouter, Request

router = APIRouter()

@router.post("/parse")
async def parse_command(request: Request):
    """
    Endpoint de test ultra-robuste.
    Lit la requête brute pour éviter toute erreur de validation Pydantic/FastAPI.
    """
    print("✅ DEBUG BACKEND: Endpoint /parse atteint !")
    
    text = "Texte par défaut"
    try:
        body = await request.json()
        print(f"✅ DEBUG BACKEND: Body reçu : {body}")
        text = body.get('text', text)
        user_tz = body.get('user_timezone', "UTC") 
        local_time = body.get('local_time')
        language = body.get('language', 'auto')
        
        print(f"✅ DEBUG BACKEND: Timezone: {user_tz}, Local Time: {local_time}, Language: {language}")
    except Exception as e:
        print(f"⚠️ DEBUG BACKEND: Erreur lecture JSON: {e}")
        user_tz = "UTC"
        local_time = None
        language = 'auto'
    
    # Tentative d'utilisation du Service Intelligent
    try:
        from app.services.voice_service import VoiceParsingService
        print(f"🤖 AI ENGINE: Tentative de parsing intelligent (Lang: {language})...")
        event_data = VoiceParsingService.parse_natural_language(
            text, 
            user_timezone=user_tz, 
            reference_time=local_time,
            language_hint=language
        )
        print(f"🤖 AI ENGINE: Succès ! {event_data}")
        
        # Conversion Pydantic -> Dict pour la réponse JSON
        return {
            "id": "ai_generated_id",
            "title": event_data.title,
            "start_time": event_data.start_time.isoformat(),
            "end_time": event_data.end_time.isoformat(),
            "location": event_data.location,
            "status": event_data.status,
            "category_id": event_data.category_id,
            "metadata": event_data.metadata or {}
        }
    except Exception as e:
        print(f"❌ AI ENGINE ERROR: Le service a échoué ({e}). Passage en mode SECOURS.")
        import traceback
        traceback.print_exc()
        
        # Fallback : Mode Echo Robust (pour ne jamais planter en 500)
        import datetime
        return {
            "id": "fallback_id_robust",
            "title": f"Fallback (Erreur IA): {text}",
            "start_time": datetime.datetime.now().isoformat(),
            "end_time": (datetime.datetime.now() + datetime.timedelta(hours=1)).isoformat(),
            "location": "Server Fallback",
            "status": "confirmed",
            "category_id": None
        }
