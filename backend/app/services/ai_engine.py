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
    def detect_conflicts(new_event: EventCreate, existing_events: List[Event], user_timezone_str: str = "UTC") -> List[Event]:
        """
        Retourne la liste des événements en conflit.
        Chevauchement: start_new < end_existing AND start_existing < end_new
        """
        conflicts = []
        from datetime import timezone, timedelta
        import re

        # Helper pour parser l'offset "UTC+HH:MM" ou "UTC-HH:MM"
        def parse_tz_offset(tz_str):
            try:
                if not tz_str or tz_str == "UTC":
                    return timezone.utc
                
                # Format attendu: UTC+01:00 ou UTC-05:00
                match = re.match(r"UTC([+-])(\d{2}):(\d{2})", tz_str)
                if match:
                    sign = 1 if match.group(1) == '+' else -1
                    hours = int(match.group(2))
                    minutes = int(match.group(3))
                    return timezone(timedelta(hours=sign * hours, minutes=sign * minutes))
            except:
                pass
            return timezone.utc

        user_tz = parse_tz_offset(user_timezone_str)

        def to_aware_utc(dt, is_db_source=False):
            if dt is None: return None
            
            # Si l'objet a déjà un tzinfo (ex: suffixe Z de l'ISO envoyé par l'app)
            if dt.tzinfo is not None:
                return dt.astimezone(timezone.utc)
            
            # Sinon, c'est Naive
            if is_db_source:
                # La DB Supabase stocke en UTC - on recupere en naive, donc on replace simplement
                return dt.replace(tzinfo=timezone.utc)
            else:
                # Naive venant de l'App : on applique le fuseau de l'utilisateur
                return dt.replace(tzinfo=user_tz).astimezone(timezone.utc)

        try:
            n_start = to_aware_utc(new_event.start_time, is_db_source=False)
            n_end = to_aware_utc(new_event.end_time, is_db_source=False)
            
            print(f"DEBUG AI: Checking conflicts for '{new_event.title}'")
            print(f"         Requested (User TZ {user_timezone_str}): {new_event.start_time} -> {new_event.end_time}")
            print(f"         Normalized (UTC): {n_start} -> {n_end}")

            for existing in existing_events:
                try:
                    e_start = to_aware_utc(existing.start_time, is_db_source=True)
                    e_end = to_aware_utc(existing.end_time, is_db_source=True)
                    
                    # Check overlap
                    if n_start < e_end and e_start < n_end:
                         print(f"🚨 CONFLICT FOUND with existing event: '{existing.title}' ({e_start} -> {e_end} UTC)")
                         conflicts.append(existing)
                except Exception as e:
                    print(f"WARN: Erreur comparaison date event {existing.id}: {e}")
                    pass
                    
        except Exception as global_e:
            print(f"CRITICAL AI ERROR in detect_conflicts: {global_e}")
            import traceback
            traceback.print_exc()
            
        return conflicts

    @staticmethod
    def find_suggestions(
        event_in: EventCreate, 
        existing_events: List[Event], 
        user_timezone_str: str = "UTC", 
        chronotype: str = "neutre"
    ) -> List[dict]:
        """
        Trouve des créneaux libres en tenant compte du profil énergétique (Chronotype).
        """
        from datetime import timedelta, timezone
        import re

        def parse_tz(tz_str):
            try:
                if not tz_str or tz_str == "UTC": return timezone.utc
                match = re.match(r"UTC([+-])(\d{2}):(\d{2})", tz_str)
                if match:
                    sign = 1 if match.group(1) == '+' else -1
                    return timezone(timedelta(hours=sign * int(match.group(2)), minutes=sign * int(match.group(3))))
            except: pass
            return timezone.utc

        user_tz = parse_tz(user_timezone_str)
        duration = event_in.end_time - event_in.start_time
        importance = event_in.metadata.get("importance_score", 2) if event_in.metadata else 2
        
        current_attempt = event_in.start_time.replace(tzinfo=user_tz)
        suggestions = []
        
        def is_slot_free(start, end, existing):
            s_utc = start.astimezone(timezone.utc)
            e_utc = end.astimezone(timezone.utc)
            for e in existing:
                e_start = e.start_time.replace(tzinfo=timezone.utc) if e.start_time.tzinfo is None else e.start_time.astimezone(timezone.utc)
                e_end = e.end_time.replace(tzinfo=timezone.utc) if e.end_time.tzinfo is None else e.end_time.astimezone(timezone.utc)
                if s_utc < e_end and e_start < e_utc:
                    return False
            return True

        # Périodes de Haute Énergie selon chronotype
        # Matin: 08-12h, Soir: 17-21h
        def is_high_energy_slot(dt, chrono):
            if chrono == "matin": return 8 <= dt.hour <= 12
            if chrono == "soir": return 17 <= dt.hour <= 21
            return 9 <= dt.hour <= 18 # Neutre: journée standard

        # On cherche par paliers
        max_attempts = 100 
        while len(suggestions) < 3 and max_attempts > 0:
            current_attempt += timedelta(minutes=30)
            candidate_end = current_attempt + duration
            
            # 1. Protection Nuit (23h - 06h)
            if 6 <= current_attempt.hour < 23:
                if is_slot_free(current_attempt, candidate_end, existing_events):
                    
                    # 2. Priorisation Énergie pour les scores élevés (>3)
                    # Si score élevé, on ne suggère QUE si c'est un créneau de haute énergie 
                    # OU si on a déjà fait trop d'essais (pour ne pas rester coincé)
                    is_peak = is_high_energy_slot(current_attempt, chronotype)
                    should_suggest = True
                    
                    if importance >= 3 and not is_peak and max_attempts > 50:
                        should_suggest = False # On attend un meilleur créneau
                    
                    if should_suggest:
                        now_local = datetime.now(user_tz)
                        day_prefix = "Aujourd'hui" if current_attempt.date() == now_local.date() else \
                                     "Demain" if current_attempt.date() == (now_local + timedelta(days=1)).date() else \
                                     current_attempt.strftime('%d/%m')
                        
                        label = f"{day_prefix} à {current_attempt.strftime('%H:%M')}"
                        if is_peak and importance >= 3:
                            label += " (Optimal ⚡)"

                        suggestions.append({
                            "start_time": current_attempt.isoformat(),
                            "end_time": candidate_end.isoformat(),
                            "label": label
                        })
            
            max_attempts -= 1

        return suggestions

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
