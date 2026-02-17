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
    def find_suggestions(event_in: EventCreate, existing_events: List[Event], user_timezone_str: str = "UTC") -> List[dict]:
        """
        Trouve des créneaux libres pour suggérer une reprogrammation.
        """
        from datetime import timedelta, timezone
        import re

        # Helper pour parser l'offset (copié de detect_conflicts pour autonomie)
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
        
        # On cherche à partir du début de l'event original
        current_attempt = event_in.start_time.replace(tzinfo=user_tz)
        suggestions = []
        
        def is_slot_free(start, end, existing):
            # Normaliser en UTC pour comparaison
            s_utc = start.astimezone(timezone.utc)
            e_utc = end.astimezone(timezone.utc)
            for e in existing:
                e_start = e.start_time.replace(tzinfo=timezone.utc) if e.start_time.tzinfo is None else e.start_time.astimezone(timezone.utc)
                e_end = e.end_time.replace(tzinfo=timezone.utc) if e.end_time.tzinfo is None else e.end_time.astimezone(timezone.utc)
                if s_utc < e_end and e_start < e_utc:
                    return False
            return True

        # Stratégie simple : On décale par paliers de 30 min sur les 48 prochaines heures
        max_attempts = 48 * 2 
        while len(suggestions) < 2 and max_attempts > 0:
            current_attempt += timedelta(minutes=30)
            candidate_end = current_attempt + duration
            
            # Éviter la nuit profonde (22h - 07h en local)
            if 7 <= current_attempt.hour < 22:
                if is_slot_free(current_attempt, candidate_end, existing_events):
                    # Génération d'un label intelligent avec le jour
                    now_local = datetime.now(user_tz)
                    if current_attempt.date() == now_local.date():
                        day_prefix = "Aujourd'hui"
                    elif current_attempt.date() == (now_local + timedelta(days=1)).date():
                        day_prefix = "Demain"
                    else:
                        day_prefix = current_attempt.strftime('%d/%m')
                    
                    suggestions.append({
                        "start_time": current_attempt.isoformat(),
                        "end_time": candidate_end.isoformat(),
                        "label": f"{day_prefix} à {current_attempt.strftime('%H:%M')}"
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
