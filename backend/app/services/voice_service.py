import json
from datetime import datetime, timedelta
from typing import Optional
from app.core.config import settings
from app.schemas.event import EventCreate

class VoiceParsingService:
    
    @staticmethod
    def parse_natural_language(text: str, user_timezone: str = "UTC", reference_time: str = None) -> EventCreate:
        """
        Orchestrateur Principal : Stratégie de Cascade (Failover).
        Ordre : Groq (Rapide) -> Gemini (Google) -> OpenAI (Si clé) -> Mock (Secours)
        """
        errors = []
        
        # If no reference time provided, fallback to server time (UTC)
        if not reference_time:
             reference_time = datetime.now().isoformat()

        # 1. TENTATIVE GROQ (Priorité Vitesse/Gratuit)
        if settings.GROQ_API_KEY:
            try:
                print("🤖 AI ENGINE: Trying Provider 'GROQ'...")
                return VoiceParsingService._parse_with_groq(text, user_timezone, reference_time)
            except Exception as e:
                print(f"⚠️ Failover: Groq failed ({e}). Switching to next...")
                errors.append(f"Groq: {e}")

        # 2. TENTATIVE GEMINI (Backup Puissant)
        if settings.GEMINI_API_KEY:
            try:
                print("🤖 AI ENGINE: Trying Provider 'GEMINI'...")
        # 2. TENTATIVE GEMINI (Backup Puissant)
        if settings.GEMINI_API_KEY:
            try:
                print("🤖 AI ENGINE: Trying Provider 'GEMINI'...")
                return VoiceParsingService._parse_with_gemini(text, user_timezone, reference_time)
            except Exception as e:
                print(f"⚠️ Failover: Gemini failed ({e}). Switching to next...")
                errors.append(f"Gemini: {e}")

        # 3. TENTATIVE OPENAI (Dernier recours payant)
        if settings.OPENAI_API_KEY:
            try:
                print("🤖 AI ENGINE: Trying Provider 'OPENAI'...")
        # 3. TENTATIVE OPENAI (Dernier recours payant)
        if settings.OPENAI_API_KEY:
            try:
                print("🤖 AI ENGINE: Trying Provider 'OPENAI'...")
                return VoiceParsingService._parse_with_openai(text, user_timezone, reference_time)
            except Exception as e:
                errors.append(f"OpenAI: {e}")
                
        # 4. MOCK FALLBACK (Sécurité ultime)
        print("❌ AI ALL PROVIDERS FAILED.")
        print(f"   Errors: {errors}")
        print("⚠️ Mode SECURE activé (Regex/Mock).")
        return VoiceParsingService._get_mock_response(text)

    # --- PROVIDER: GROQ (LLAMA 3) ---
    @staticmethod
    def _parse_with_groq(text: str, user_timezone: str, current_time: str) -> EventCreate:
        from groq import Groq
        
        if not settings.GROQ_API_KEY:
            raise ValueError("GROQ_API_KEY manquante.")

        client = Groq(api_key=settings.GROQ_API_KEY)
        # current_time is passed as argument
        
        system_prompt = VoiceParsingService._get_system_prompt(current_time, user_timezone)

        # Llama 3 on Groq
        print("🤖 AI ENGINE: Using Groq (Llama-3.3-70b-versatile)...")
        
        completion = client.chat.completions.create(
            model="llama-3.3-70b-versatile", # Or "llama3-70b-8192"
            messages=[
                {"role": "system", "content": system_prompt + "\n\nIMPORTANT: REPONDS UNIQUEMENT AVEC LE JSON. PAS DE TEXTE AVANT OU APRES."},
                {"role": "user", "content": text}
            ],
            temperature=0,
            stream=False,
            response_format={"type": "json_object"}
        )
        
        json_content = completion.choices[0].message.content
        print(f"✅ Groq Response: {json_content[:100]}...")
        
        data = json.loads(json_content)
        
        # Adaptation Schema
        meta = data.get("metadata", {})
        
        # NOTE / DESCRIPTION
        desc = data.pop("description", None)
        if desc:
            meta["note"] = desc

        # Robust Category
        cat = data.pop("category", None) or data.pop("Category", None)
        if cat:
            meta["suggested_category"] = cat.capitalize()
            
        # Robust Importance
        score = data.pop("importance_score", None) or data.pop("importance", None)
        if score:
            try:
                meta["importance_score"] = int(score)
            except:
                meta["importance_score"] = 2
                
        data["metadata"] = meta
        
        return EventCreate(**data)


    # --- PROVIDER: OPENAI ---
    @staticmethod
    def _parse_with_openai(text: str, user_timezone: str, current_time: str) -> EventCreate:
        from openai import OpenAI
        
        if not settings.OPENAI_API_KEY:
            raise ValueError("OPENAI_API_KEY manquante.")

        client = OpenAI(api_key=settings.OPENAI_API_KEY)
        # current_time is passed as argument
        
        system_prompt = VoiceParsingService._get_system_prompt(current_time, user_timezone)

        response = client.chat.completions.create(
            model=settings.OPENAI_MODEL,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": text}
            ],
            temperature=0,
            response_format={"type": "json_object"}
        )
        
        json_content = response.choices[0].message.content
        data = json.loads(json_content)
        
        # Adaptation Schema
        meta = data.get("metadata", {})
        if "category" in data:
             meta["suggested_category"] = data.pop("category")
        if "importance_score" in data:
             meta["importance_score"] = data.pop("importance_score")
        data["metadata"] = meta
        
        return EventCreate(**data)

    # --- PROVIDER: GOOGLE GEMINI ---
    @staticmethod
    def _parse_with_gemini(text: str, user_timezone: str, current_time: str) -> EventCreate:
        import google.generativeai as genai
        
        if not settings.GEMINI_API_KEY:
            raise ValueError("GEMINI_API_KEY manquante.")

        genai.configure(api_key=settings.GEMINI_API_KEY)
        
        # DEBUG: Lister les modèles disponibles pour trouver le bon nom
        print("🤖 AI ENGINE DEBUG: Listing available Gemini models...")
        try:
            for m in genai.list_models():
                if 'generateContent' in m.supported_generation_methods:
                    print(f"   - Model found: {m.name}")
        except Exception as e:
            print(f"   ❌ Failed to list models: {e}")

        # Configuration spécifique pour forcer le JSON
        generation_config = {
            "temperature": 0.0,
            "top_p": 0.95,
            "top_k": 64,
            "max_output_tokens": 8192,
            "response_mime_type": "application/json",


        system_prompt = VoiceParsingService._get_system_prompt(current_time, user_timezone)
        full_prompt = f"{system_prompt}\n\nUSER REQUEST: {text}"

        # Liste des modèles détectés comme disponibles pour l'utilisateur
        # PRIORITÉ AU PRO (Compte Payant - Quotas élevés)
        candidate_models = [
            "models/gemini-2.5-pro", # Latest Stable Pro
            "models/gemini-2.5-flash", # Latest Stable Flash
            "models/gemini-2.0-flash", # Previous Stable
            "models/gemini-pro-latest", # Classic Alias
            # Fallbacks
            "models/gemini-flash-latest",
        ]
        
        last_error = None
        
        for model_name in candidate_models:
            print(f"🤖 Tentative Gemini avec modèle : {model_name}...")
            try:
                model = genai.GenerativeModel(
                    model_name=model_name,
                    generation_config=generation_config,
                )
                
                chat_session = model.start_chat(history=[])
                response = chat_session.send_message(full_prompt)
                
                # Nettoyage si jamais Gemini met des backticks ```json ... ```
                raw_text = response.text
                if raw_text.startswith("```json"):
                    raw_text = raw_text[7:]
                if raw_text.endswith("```"):
                    raw_text = raw_text[:-3]
                    
                print(f"✅ Succès Gemini ({model_name})")
                data = json.loads(raw_text)
                
                # Adaptation pour Schema
                meta = data.get("metadata", {})
                
                # NOTE / DESCRIPTION
                desc = data.pop("description", None)
                if desc:
                    meta["note"] = desc

                # Robust extraction of Category
                cat = data.pop("category", None) or data.pop("Category", None)
                if cat:
                    meta["suggested_category"] = cat.capitalize() # Force capitalized
                
                # Clamp Importance Score
                score = data.pop("importance_score", None) or data.pop("importance", None)
                if score:
                    try:
                        s = int(score)
                        meta["importance_score"] = max(1, min(10, s)) # Clamp 1-10
                    except:
                        meta["importance_score"] = 5
                        
                data["metadata"] = meta
                
                return EventCreate(**data)
                
            except Exception as e:
                print(f"⚠️ Échec modèle {model_name}: {e}")
                last_error = e
                continue
        
        # Si on arrive ici, tous les modèles ont échoué
        print("❌ TOUS LES MODÈLES ONT ÉCHOUÉ. Liste des erreurs ci-dessus.")
        # Fallback Mock manuel ici pour éviter le crash 500
        return VoiceParsingService._get_mock_response(text)

    # --- UTILS ---
    @staticmethod
    def _get_system_prompt(current_time: str, timezone: str) -> str:
        return f"""
        Tu es un assistant personnel expert en gestion d'agenda.
        Nous sommes le {current_time} (Timezone: {timezone}).
        Ta mission : Extraire les détails d'un événement à partir du texte utilisateur.
        
        Retourne UNIQUEMENT un JSON valide respectant ce format :
        {{
            "title": "Titre explicite",
            "start_time": "ISO8601",
            "end_time": "ISO8601 (si non précisé, durée par défaut = 1h)",
            "location": "Lieu ou null",
            "description": "Notes, détails ou contexte (ex: nom du film, sujet réunion...)",
            "category": "Nom de la catégorie déduite (Ex: Travail, Perso, Études, Sport...)",
            "importance_score": 1, 2, 3 ou 4 (1=Faible, 2=Moyenne, 3=Haute, 4=Urgente),
            "status": "confirmed"
        }}
        
        Règles :
        - Pour "demain", calcule la date exacte.
        - Catégories : Suggère la catégorie la plus pertinente. (Ex: 'Études' pour un cours, 'Santé' pour médecin, etc.). Ne te limite pas strictment si le contexte est clair.
        - Importance : 1 (trivial), 2 (normal), 3 (important), 4 (critique/vital).
        - CAS PARTICULIER : Si l'utilisateur exprime une idée vague sans date ("Penser à..."), créer une NOTE (Start=Maintenant, Durée=15min).
        - CAS REFUS : Si l'utilisateur raconte une histoire, bavarde, ou dit quelque chose sans rapport avec une action d'agenda (ex: "Papa a dit que...", "Quelle est la capitale", "Insulte"),
          Retourne : Title="ERREUR", Status="cancelled", Metadata={{"error_message": "Ceci n'est pas une tâche d'agenda."}}.
        """

    # --- MOCK FALLBACK (SMART) ---
    @staticmethod
    def _get_mock_response(text: str) -> EventCreate:
        print(f"[VoiceService] MODE MOCK/FALLBACK. Prompt : {text}")
        try:
            now = datetime.now()
            import re
            
            # --- Parsing Regex Heuristique ---
            
            # 1. Détection "dans X minutes"
            # Ex: "Dans 16 min", "dans 5 minutes"
            start_offset = 0
            match_start = re.search(r"dans\s+(\d+)\s*(min|minutes?)", text.lower())
            if match_start:
                start_offset = int(match_start.group(1))
            
            # 2. Détection "dure X minutes"
            # Ex: "dure 30 min", "pendant 1h"
            duration = 60 # Default 1h
            match_duration = re.search(r"(dure|durée)\s*(\d+)\s*(min|minutes?)", text.lower())
            if match_duration:
                duration = int(match_duration.group(1))

            # Calcul Start Time
            start_mock = now + timedelta(minutes=start_offset)
            
            # Si pas de 'dans X min', mais 'demain'
            if start_offset == 0 and "demain" in text.lower():
                 start_mock = start_mock + timedelta(days=1)
                 start_mock = start_mock.replace(hour=9, minute=0, second=0)
            
            # Si aucun indice temporel, on décale un peu pour éviter doublon immédiat
            if start_offset == 0 and "demain" not in text.lower():
                import random
                jitter = random.randint(1, 59) # Jitter 1-59 min
                # On met ça demain par défaut pour ne pas polluer l'immédiat
                start_mock = start_mock + timedelta(days=1) 
                start_mock = start_mock.replace(hour=10, minute=jitter, second=0)

            end_mock = start_mock + timedelta(minutes=duration)
            
            # --- Nettoyage Titre ---
            clean_title = text
            # On retire les patterns temporels reconnus pour nettoyer le titre
            clean_title = re.sub(r"dans\s+(\d+)\s*(min|minutes?)", "", clean_title, flags=re.IGNORECASE)
            clean_title = re.sub(r"(dure|durée)\s*(\d+)\s*(min|minutes?)", "", clean_title, flags=re.IGNORECASE)
            # Remove filler words
            clean_title = re.sub(r"^(je veux|ajoute|cr[ée]er?|j'ai|il y a|c'est)\s+(un|une|le|la)?", "", clean_title, flags=re.IGNORECASE)
            clean_title = re.sub(r"qui commence", "", clean_title, flags=re.IGNORECASE)
            clean_title = re.sub(r"le cours", "", clean_title, flags=re.IGNORECASE)
            
            clean_title = clean_title.strip().capitalize()
            # Nettoyage ponctuation fin
            if clean_title.endswith("."): clean_title = clean_title[:-1]

            if len(clean_title) < 3: 
                clean_title = text # Fallback si nettoyage trop agressif

            # --- Detect Category Keywords ---
            suggested_cat = "Autre"
            score = 2
            txt_lower = text.lower()
            
            if any(w in txt_lower for w in ["boulot", "travail", "réunion", "meeting", "boss", "projet", "client", "math", "cours", "école", "examen"]):
                suggested_cat = "Travail"
                score = 3
            elif any(w in txt_lower for w in ["docteur", "médecin", "dentiste", "santé", "hôpital", "sport", "basket", "foot", "yoga", "gym"]):
                suggested_cat = "Santé"
                score = 4 if "docteur" in txt_lower or "hopital" in txt_lower else 3
            elif any(w in txt_lower for w in ["famille", "maman", "papa", "anniversaire", "fête", "enfant", "maison", "courses"]):
                suggested_cat = "Personnel"
                score = 3
            elif any(w in txt_lower for w in ["banque", "impôt", "facture", "payer", "loyer", "virement"]):
                suggested_cat = "Finance"
                score = 4
            elif any(w in txt_lower for w in ["ami", "pote", "soirée", "bar", "resto", "ciné", "bière"]):
                suggested_cat = "Social"
                score = 3

            return EventCreate(
                title=clean_title, 
                start_time=start_mock,
                end_time=end_mock,
                location="À définir",
                status="confirmed",
                metadata={
                    "origin": "mock_smart_fallback",
                    "suggested_category": suggested_cat, 
                    "importance_score": score,
                    "note": f"Généré sans IA (Quota). Texte original: {text}"
                }
            )
        except Exception as e:
            print(f"ERROR Mock Fallback: {e}")
            return EventCreate(
                title=text[:30] + "...",
                start_time=datetime.now() + timedelta(days=1),
                end_time=datetime.now() + timedelta(days=1, hours=1),
                status="confirmed",
                metadata={"origin": "mock_panic", "importance_score": 1}
            )
