from typing import List, Any
from datetime import timezone
from fastapi import APIRouter, HTTPException, Query, Request
from app.schemas.event import Event, EventCreate, EventUpdate
from app.services.event_service import EventService

router = APIRouter()

# Helper to extract User ID from JWT (Supabase)
import jwt

def get_current_user_id(authorization: str):
    try:
        if not authorization:
             raise HTTPException(status_code=401, detail="Missing Token")
        
        parts = authorization.split(" ")
        if len(parts) != 2 or parts[0].lower() != "bearer":
             raise HTTPException(status_code=401, detail="Invalid Header Format")
             
        token = parts[1]

        # --- BYPASS DEMO MODE ---
        if token == "demo-token":
            return "00000000-0000-0000-0000-000000000000"

        # Decode without verifying signature (requires secret) - Trusting the bearer for now 
        payload = jwt.decode(token, options={"verify_signature": False})
        return payload.get("sub")
    except Exception as e:
        print(f"AUTH ERROR: {e}")
        raise HTTPException(status_code=401, detail="Invalid Token")

@router.get("/", response_model=List[dict])
async def read_events(
    request: Request,
    skip: int = 0,
    limit: int = 100,
):
    """
    Retrieve user events.
    """
    try:
        user_id = get_current_user_id(request.headers.get("Authorization"))
        events = EventService.get_user_events(user_id)
        return events
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/", response_model=dict)
async def create_event(
    request: Request,
    event_in: EventCreate,
    force: bool = Query(False)
):
    """
    Create new event with AI checks.
    """
    try:
        user_id = get_current_user_id(request.headers.get("Authorization"))
        print(f"DEBUG: Start create_event with user {user_id} (force={force})")
        
        # 1. Recuperer les events existants pour check conflits
        raw_events = EventService.get_user_events(user_id)
        
        existing_events = []
        for e in raw_events:
            try:
                existing_events.append(Event.model_validate(e))
            except Exception as ev_err:
                print(f"WARN: Failed to validate existing event {e.get('id')}: {ev_err}")

        # 1.5 Dédoublonnage Anti-Spam
        for existing in existing_events:
            # On compare en UTC normalisé pour être sur
            e_start = existing.start_time.replace(tzinfo=timezone.utc) if existing.start_time.tzinfo is None else existing.start_time.astimezone(timezone.utc)
            new_start = event_in.start_time.replace(tzinfo=timezone.utc) if event_in.start_time.tzinfo is None else event_in.start_time.astimezone(timezone.utc)
            
            if existing.title == event_in.title and e_start == new_start:
                 print(f"DEBUG: Duplicate detected for '{event_in.title}' at {new_start}")
                 return {
                    "id": str(existing.id),
                    "status": "duplicate_ignored",
                    "code": "duplicate",
                    "message": "Cet événement existe déjà à cet horaire."
                 }

        # 2. Check Conflits (Uniquement si force=False)
        from app.services.ai_engine import AIEngine
        from app.services.profile_service import ProfileService
        
        user_tz = request.headers.get("X-User-Timezone", "UTC")
        profile = ProfileService.get_profile(user_id)
        chrono = profile.get("chronotype", "neutre") if profile else "neutre"

        conflicts = AIEngine.detect_conflicts(event_in, existing_events, user_timezone_str=user_tz)
        
        if conflicts and not force:
            conflict_ids = [str(c.id) for c in conflicts]
            conflict_titles = [c.title for c in conflicts]
            
            # AI suggestions for next free slots (CHRONOTYPE AWARE)
            suggestions = AIEngine.find_suggestions(event_in, existing_events, user_timezone_str=user_tz, chronotype=chrono)
            
            raise HTTPException(
                status_code=409,
                detail={
                    "code": "conflict_detected",
                    "message": f"Conflit détecté avec : {', '.join(conflict_titles)}",
                    "conflicting_events": conflict_ids,
                    "suggestions": suggestions
                }
            )

        # 3. Calcul Score
        current_score = event_in.metadata.get("importance_score", 0) if event_in.metadata else 0
        
        if current_score == 0:
            print("DEBUG: Calculating score (AI score missing)...")
            importance = AIEngine.calculate_importance_score(event_in)
            if event_in.metadata is None:
                event_in.metadata = {}
            event_in.metadata["importance_score"] = importance
        else:
             print(f"DEBUG: Preserving AI Score: {current_score}")
        print(f"DEBUG: Metadata updated. calling create_event...")

        return EventService.create_event(user_id, event_in)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.patch("/{event_id}", response_model=dict)
async def update_event(
    request: Request,
    event_id: str,
    event_in: EventUpdate,
    force: bool = Query(False)
):
    """
    Update an event with conflict checks.
    """
    try:
        user_id = get_current_user_id(request.headers.get("Authorization"))
        
        # Check conflicts ONLY if time is changing or force is not used
        # To be safe, we check if start_time or end_time is in event_in
        if (event_in.start_time or event_in.end_time) and not force:
            raw_events = EventService.get_user_events(user_id)
            existing_events = []
            for e in raw_events:
                if str(e.get("id")) != event_id: # EXCLUDE self
                    try:
                        existing_events.append(Event.model_validate(e))
                    except: pass

            # Merge update with current event for detection
            # 1. Get current event
            all_raw = EventService.get_user_events(user_id)
            current_raw = next((e for e in all_raw if str(e.get("id")) == event_id), None)
            if not current_raw:
                raise HTTPException(status_code=404, detail="Evénement introuvable")
            
            current_event = Event.model_validate(current_raw)
            # Create a virtual event for detection
            detector_event = current_event.model_copy(update=event_in.model_dump(exclude_unset=True))

            from app.services.ai_engine import AIEngine
            from app.services.profile_service import ProfileService
            
            user_tz = request.headers.get("X-User-Timezone", "UTC")
            profile = ProfileService.get_profile(user_id)
            chrono = profile.get("chronotype", "neutre") if profile else "neutre"

            conflicts = AIEngine.detect_conflicts(detector_event, existing_events, user_timezone_str=user_tz)
            
            if conflicts:
                conflict_titles = [c.title for c in conflicts]
                # AI Suggestions (CHRONOTYPE AWARE)
                suggestions = AIEngine.find_suggestions(detector_event, existing_events, user_timezone_str=user_tz, chronotype=chrono)
                raise HTTPException(
                    status_code=409,
                    detail={
                        "code": "conflict_detected",
                        "message": f"Conflit détecté avec : {', '.join(conflict_titles)}",
                        "conflicting_events": [str(c.id) for c in conflicts],
                        "suggestions": suggestions
                    }
                )

        return EventService.update_event(user_id, event_id, event_in)
    except HTTPException:
        raise
    except Exception as e:
        print(f"ERROR UPDATE EVENT: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{event_id}")
async def delete_event(
    request: Request,
    event_id: str,
):
    """
    Delete an event.
    """
    try:
        user_id = get_current_user_id(request.headers.get("Authorization"))
        EventService.delete_event(user_id, event_id)
        return {"status": "success"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
