from typing import List, Any
from fastapi import APIRouter, HTTPException, Query
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
):
    """
    Create new event with AI checks.
    """
    try:
        user_id = get_current_user_id(request.headers.get("Authorization"))
        print(f"DEBUG: Start create_event with user {user_id}")
        
        # 1. Recuperer les events existants pour check conflits
        raw_events = EventService.get_user_events(user_id)
        print(f"DEBUG: Raw events count: {len(raw_events)}")
        
        existing_events = []
        for e in raw_events:
            try:
                existing_events.append(Event.model_validate(e))
            except Exception as ev_err:
                print(f"WARN: Failed to validate existing event {e.get('id')}: {ev_err}")

        print(f"DEBUG: Validated events: {len(existing_events)}")
        
        # 1.5 Dédoublonnage Anti-Spam
        for existing in existing_events:
            if existing.title == event_in.title and existing.start_time == event_in.start_time:
                 print(f"🚨 DUPLICATE DETECTED: {event_in.title}. Returning existing one.")
                 return {
                    "id": str(existing.id),
                    "status": "duplicate_ignored",
                    "message": "Doublon détecté et ignoré."
                 }

        # 2. Check Conflits
        from app.services.ai_engine import AIEngine
        print("DEBUG: Checking conflicts...")
        conflicts = AIEngine.detect_conflicts(event_in, existing_events)
        print(f"DEBUG: Conflicts found: {len(conflicts)}")
        
        if conflicts:
            conflict_ids = [str(c.id) for c in conflicts]
            raise HTTPException(
                status_code=409,
                detail={
                    "code": "conflict_detected",
                    "message": f"Conflit détecté avec {len(conflicts)} événement(s).",
                    "conflicting_events": conflict_ids
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
):
    """
    Update an event.
    """
    try:
        user_id = get_current_user_id(request.headers.get("Authorization"))
        return EventService.update_event(user_id, event_id, event_in)
    except Exception as e:
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
