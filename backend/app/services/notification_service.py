from datetime import datetime, timedelta

class NotificationService:
    
    DEFAULT_PREP_TIME = 15 # minutes
    DEFAULT_BUFFER_TIME = 10 # minutes
    AVERAGE_SPEED_KMH = 30 # km/h (ville)

    @staticmethod
    def calculate_time_to_leave(event_start: datetime, distance_km: float = 5.0) -> datetime:
        """
        Calcule l'heure de départ idéale.
        TTL = Start - (Trajet + Prep + Buffer)
        """
        # Mock Trajet (Vitesse moyenne)
        travel_time_minutes = (distance_km / NotificationService.AVERAGE_SPEED_KMH) * 60
        
        total_offset = travel_time_minutes + NotificationService.DEFAULT_PREP_TIME + NotificationService.DEFAULT_BUFFER_TIME
        
        return event_start - timedelta(minutes=total_offset)

    @staticmethod
    def generate_notification_message(event_title: str, time_to_leave: datetime) -> str:
        """
        Génère le message de notification.
        """
        now = datetime.now()
        minutes_left = int((time_to_leave - now).total_seconds() / 60)
        
        if minutes_left > 60:
            return f"Préparez-vous pour '{event_title}'. Départ conseillé à {time_to_leave.strftime('%H:%M')}."
        elif minutes_left > 0:
            return f"Départ dans {minutes_left} min pour '{event_title}' !"
        else:
            return f"URGENT : Vous devriez être parti pour '{event_title}' !"
