from datetime import datetime
from uuid import UUID
from typing import List, Dict
from app.schemas.event import Event, EventCreate

class AIEngine:
    
    # Poids de base par catégorie (Mock - à récupérer en DB idéalement)
    CATEGORY_WEIGHTS = {
        "health": 90,
        "work_client": 80,
        "work_internal": 60,
        "social": 50,
        "personal": 40
    }

    @staticmethod
    def calculate_importance_score(event: EventCreate, category_name: str = "personal") -> int:
        """
        Calcule le Score d'Importance (IS) d'un événement.
        IS = (Poids Catégorie) + Bonus
        """
        base_score = AIEngine.CATEGORY_WEIGHTS.get(category_name, 40)
        
        # Bonus contextuel simple
        bonus = 0
        # Ex: Si 'important' est dans le titre
        if "important" in event.title.lower() or "urgenc" in event.title.lower():
            bonus += 20
            
        final_score = base_score + bonus
        return min(final_score, 100) # Max 100

    @staticmethod
    def detect_conflicts(new_event: EventCreate, existing_events: List[Event]) -> List[Event]:
        """
        Retourne la liste des événements en conflit.
        Chevauchement: start_new < end_existing AND start_existing < end_new
        """
        conflicts = []
        from datetime import timezone

        # Helper pour normaliser en UTC Aware
        def to_aware_utc(dt, is_db_source=False):
            if dt.tzinfo is not None:
                return dt.astimezone(timezone.utc)
            
            # Si Naive
            if is_db_source:
                # DB (Supabase/MOCK) est généralement en UTC Naive
                return dt.replace(tzinfo=timezone.utc)
            else:
                # Input App (Flutter) est généralement en Local Naive
                # On utilise l'astuce .astimezone() sur un naive "now" pour chopper la TZ locale
                return dt.astimezone(timezone.utc)

        try:
            n_start = to_aware_utc(new_event.start_time, is_db_source=False)
            n_end = to_aware_utc(new_event.end_time, is_db_source=False)
            
            # print(f"DEBUG: Check Conflict New (UTC) [{n_start} - {n_end}]")

            for existing in existing_events:
                try:
                    e_start = to_aware_utc(existing.start_time, is_db_source=True)
                    e_end = to_aware_utc(existing.end_time, is_db_source=True)
                    
                    # On ne log que si proche pour éviter le spam
                    # print(f"DEBUG: vs Existing (UTC) [{e_start} - {e_end}]")
                    
                    # Check overlap
                    if n_start < e_end and e_start < n_end:
                         print(f"🚨 CONFLICT FOUND with {existing.title}")
                         conflicts.append(existing)
                except Exception as e:
                    # print(f"WARN: Erreur comparaison date event {existing.id}: {e}")
                    pass
                    
        except Exception as global_e:
            print(f"CRITICAL AI ERROR: {global_e}")
            
        return conflicts

    @staticmethod
    def analyze_conflict_severity(new_score: int, existing_score: int) -> str:
        """
        Détermine l'action à prendre selon la différence de score.
        """
        diff = new_score - existing_score
        
        if diff > 20:
            return "crush" # L'ancien dégage (proposition)
        elif abs(diff) <= 20: 
            return "negotiate" # Conflit dur, faut choisir
        else:
            return "reject" # Le nouveau est trop faible
