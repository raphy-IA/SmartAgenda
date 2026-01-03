from typing import List, Any
from fastapi import APIRouter, HTTPException, Query
from app.schemas.event import Event, EventCreate, EventUpdate
from app.services.event_service import EventService

router = APIRouter()

# TODO: Add authentication middleware to get current_user_id
# For now, we simulate a user_id
FAKE_USER_ID = "00000000-0000-0000-0000-000000000000"

@router.get("/", response_model=List[dict])
async def read_events(
    skip: int = 0,
    limit: int = 100,
):
    """
    Retrieve user events.
    """
    try:
        events = EventService.get_user_events(FAKE_USER_ID)
        return events
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/", response_model=dict)
async def create_event(
    event_in: EventCreate,
):
    """
    Create new event with AI checks.
    """
    try:
        print(f"DEBUG: Start create_event with user {FAKE_USER_ID}")
        # 1. Recuperer les events existants pour check conflits
        raw_events = EventService.get_user_events(FAKE_USER_ID)
        print(f"DEBUG: Raw events count: {len(raw_events)}")
        
        existing_events = []
        for e in raw_events:
            try:
                existing_events.append(Event.model_validate(e))
            except Exception as ev_err:
                print(f"WARN: Failed to validate existing event {e.get('id')}: {ev_err}")

        print(f"DEBUG: Validated events: {len(existing_events)}")
        
        # 1.5 Dédoublonnage Anti-Spam (Si même titre/heure créé < 5s)
        # On compare avec les events existants
        for existing in existing_events:
            if existing.title == event_in.title and existing.start_time == event_in.start_time:
                 print(f"🚨 DUPLICATE DETECTED: {event_in.title}. Returning existing one.")
                 return {
                    "id": str(existing.id),
                    "status": "duplicate_ignored", # Frontend peut gérer ou ignorer
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

        # 3. Calcul Score (pour info future)
        # On ne recalcule QUE si l'IA n'a rien donné (ou si score < 1)
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

        return EventService.create_event(FAKE_USER_ID, event_in)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.patch("/{event_id}", response_model=dict)
async def update_event(
    event_id: str,
    event_in: EventUpdate,
):
    """
    Update an event.
    """
    try:
        return EventService.update_event(FAKE_USER_ID, event_id, event_in)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{event_id}")
async def delete_event(
    event_id: str,
):
    """
    Delete an event.
    """
    try:
        EventService.delete_event(FAKE_USER_ID, event_id)
        return {"status": "success"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
