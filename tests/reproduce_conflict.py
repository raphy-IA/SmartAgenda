
import sys
import os
from datetime import datetime, timedelta

# Add backend to path
sys.path.append(os.path.join(os.getcwd(), 'backend'))

from app.services.ai_engine import AIEngine
from app.schemas.event import Event, EventCreate

def test_conflict():
    now = datetime.now()
    print(f"Current Time: {now}")

    # SCENARIO:
    # New Event: Starts in 16 min, Duration 30 min.
    # Existing Event: Starts in 1 hour (60 min).

    # 1. Setup Dates
    new_start = now + timedelta(minutes=16)
    new_end = new_start + timedelta(minutes=30)
    
    existing_start = now + timedelta(minutes=60)
    existing_end = existing_start + timedelta(hours=1)

    print(f"New Event:      {new_start.time()} - {new_end.time()}")
    print(f"Existing Event: {existing_start.time()} - {existing_end.time()}")

    # 2. Objects
    new_evt = EventCreate(
        title="New Event",
        start_time=new_start,
        end_time=new_end,
        location="Here",
        status="confirmed",
        metadata={}
    )

    existing_evt = Event(
        id="123",
        user_id="fake",
        title="Existing Event",
        start_time=existing_start,
        end_time=existing_end,
        location="There",
        status="confirmed",
        created_at=now,
        metadata={}
    )

    # 3. Test Detection
    conflicts = AIEngine.detect_conflicts(new_evt, [existing_evt])
    
    if conflicts:
        print(f"❌ CONFLICT DETECTED! (Unexpected)")
    else:
        print(f"✅ No Conflict (Expected)")

    # 4. Test Timezone Shift scenario
    # Imagine New Event is provided in UTC but treated as Local (or vice versa)
    # Let's say New Event is actually +1h shifted
    print("\n--- Testing Timezone Mismatch (+1h shift on New Event) ---")
    shifted_start = new_start + timedelta(hours=1)
    shifted_end = new_end + timedelta(hours=1)
    new_evt.start_time = shifted_start
    new_evt.end_time = shifted_end
    
    print(f"Shifted New:    {shifted_start.time()} - {shifted_end.time()}")
    print(f"Existing:       {existing_start.time()} - {existing_end.time()}")
    
    conflicts_shifted = AIEngine.detect_conflicts(new_evt, [existing_evt])
    if conflicts_shifted:
        print(f"❌ CONFLICT DETECTED in Shifted Scenario (This might explain it)")

if __name__ == "__main__":
    test_conflict()
