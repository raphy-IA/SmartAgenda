import sys
import os
from datetime import datetime, timedelta
from unittest.mock import MagicMock, patch

# Add backend to path
sys.path.append(os.path.join(os.getcwd(), 'backend'))

from app.schemas.event import EventCreate, Event
from app.services.ai_engine import AIEngine
from app.services.notification_service import NotificationService

def print_step(title):
    print(f"\n{'='*50}")
    print(f"🔹 ÉTAPE : {title}")
    print(f"{'='*50}")

def simulate_flow():
    print("🚀 Démarrage de la Simulation SmartAgenda AI (Mocked)")

    # 1. Simulation Commande Vocale
    print_step("1. Interaction Vocale (Simulée)")
    raw_text = "Déjeuner urgent avec le client Apple demain à 12h30 au Fouquet's"
    print(f"🗣️  Commande utilisateur : '{raw_text}'")
    
    # Mock Parsing LLM (On simule ce que GPT renverrait)
    mock_parsed_event = EventCreate(
        title="Déjeuner Client Apple",
        start_time=datetime.now() + timedelta(days=1, hours=12, minutes=30),
        end_time=datetime.now() + timedelta(days=1, hours=14, minutes=00),
        location="Le Fouquet's, Paris",
        status="confirmed"
    )
    print(f"🤖 [IA Parsing] Structure extraite : \n   Title: {mock_parsed_event.title}\n   Time: {mock_parsed_event.start_time.strftime('%Y-%m-%d %H:%M')}\n   Loc: {mock_parsed_event.location}")

    # 2. Moteur de Scoring
    print_step("2. Analyse & Scoring IA")
    # On simule l'ajout de metadata par l'IA
    score = AIEngine.calculate_importance_score(mock_parsed_event, category_name="work_client")
    print(f"📊 [IA Scoring] Score calculé : {score}/100")
    if score > 80:
        print("   -> 🔥 Événement classé HAUTE PRIORITÉ")

    # 3. Détection de Conflits
    print_step("3. Détection de Conflits")
    # Création d'un conflit artificiel
    existing_event = Event(
        id="12345678-1234-5678-1234-567812345678",
        user_id="00000000-0000-0000-0000-000000000000",
        title="Sport",
        start_time=mock_parsed_event.start_time - timedelta(minutes=30),
        end_time=mock_parsed_event.start_time + timedelta(minutes=30),
        status="confirmed",
        ai_generated=False,
        created_at=datetime.now()
    )
    print(f"📅 Agenda existant : '{existing_event.title}' prévu à {existing_event.start_time.strftime('%H:%M')}")
    
    conflicts = AIEngine.detect_conflicts(mock_parsed_event, [existing_event])
    if conflicts:
        print(f"⚠️  [IA Conflict] ALERTE : Chevauchement détecté avec '{conflicts[0].title}' !")
        severity = AIEngine.analyze_conflict_severity(score, 40) # Score sport ~40
        print(f"   -> Analyse Sévérité : Nouveau ({score}) vs Ancien (~40) => Action: {severity.upper()}")
        print("   -> Décision : L'IA suggère de déplacer le Sport.")

    # 4. Notification Intelligente
    print_step("4. Planification Notification")
    ttl = NotificationService.calculate_time_to_leave(mock_parsed_event.start_time, distance_km=10.0)
    msg = NotificationService.generate_notification_message(mock_parsed_event.title, ttl)
    print(f"🚗 [Smart Travel] Distance: 10km (Traffic fluide)")
    print(f"🔔 [Notif] Heure de départ conseillée : {ttl.strftime('%H:%M')}")
    print(f"   Message : \"{msg}\"")

    print("\n✅ Simulation Terminée avec succès.")

if __name__ == "__main__":
    simulate_flow()
