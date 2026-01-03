# Architecture Technique - SmartAgenda AI

## 1. Stack Technique Choisie

### Frontend
- **Mobile (App Principale)** : **Flutter**
    - *Pourquoi ?* Performance native, UI/UX fluide ("Premium feel"), code unique iOS/Android, excellent support des animations de micro-interactions.
- **Web (Administration / Vue Desktop)** : **Next.js (React)**
    - *Pourquoi ?* Écosystème React riche, SEO (pour la landing page), rapidité de développement, intégration facile avec les outils modernes.

### Backend & Infrastructure
- **API Priscipale** : **Python FastAPI**
    - *Pourquoi ?* Performance (New Asyncio), typage fort (Pydantic), intégration native avec les bibliothèques IA (LangChain, OpenAI SDK, Pandas).
- **Authentication & Database** : **Supabase** (PostgreSQL)
    - *Pourquoi ?* Solution "Backend-as-a-Service" complète qui gère l'Auth, la BDD temps réel (Postgres), et le Stockage. Idéal pour une petite équipe (2 pers) et un MVP rapide.
- **Orchestration IA / Tâches de fond** : **Celery** + **Redis** (optionnel si MVP simple) ou **Supabase Edge Functions** (TypeScript) pour les triggers simples. Pour le MVP, le backend FastAPI gérera les cron jobs via **APScheduler**.

## 2. Architecture Système

```mermaid
graph TD
    UserMobile[App Mobile (Flutter)] -->|REST / WebSocket| API[API Gateway (FastAPI)]
    UserWeb[App Web (Next.js)] -->|REST / WebSocket| API
    
    API -->|Auth & Data| Supabase[Supabase (PostgreSQL + Auth)]
    API -->|AI Processing| AI_Engine[Moteur IA (Interne)]
    
    AI_Engine -->|LLM Queries| OpenAI[OpenAI API (GPT-4o)]
    AI_Engine -->|Background Jobs| Scheduler[APScheduler (Rappels/Analyses)]
    
    Scheduler -->|Push Notif| FCM[Firebase Call Messaging]
```

## 3. Schéma de Base de Données (PostgreSQL)

### Tables Principales

**users**
- `id` (UUID, PK)
- `email` (String, Unique)
- `full_name` (String)
- `preferences` (JSONB): `{ "working_hours": "09:00-18:00", "default_transport": "car" }`
- `frozen_until` (Timestamp, Nullable): Si défini, l'utilisateur est en mode "Freeze".
- `created_at` (Timestamp)

**events**
- `id` (UUID, PK)
- `user_id` (UUID, FK -> users.id)
- `title` (String)
- `start_time` (Timestamp)
- `end_time` (Timestamp)
- `location` (String, Nullable)
- `category_id` (UUID, FK -> categories.id)
- `status` (Enum: 'confirmed', 'cancelled', 'tentative')
- `ai_generated` (Boolean): True si créé par l'IA.
- `metadata` (JSONB): Pour stocker des infos spécifiques (URL réunion, notes).

**categories**
- `id` (UUID, PK)
- `name` (String): Travail, Santé, Perso...
- `color_hex` (String)
- `priority_level` (Integer): 1 (Bas) à 10 (Critique).
- `is_default` (Boolean)

**reminders**
- `id` (UUID, PK)
- `event_id` (UUID, FK -> events.id)
- `scheduled_time` (Timestamp)
- `type` (Enum: 'push', 'audio', 'email')
- `status` (Enum: 'pending', 'sent', 'cancelled')
- `message_content` (Text): Message généré par l'IA (ex: "Pars maintenant pour ton RDV").

**ai_rules** (Apprentissage Comportemental)
- `id` (UUID, PK)
- `user_id` (UUID, FK)
- `pattern` (String): Description du pattern (ex: "Annule souvent le sport le vendredi").
- `confidence_score` (Float): 0.0 à 1.0.
- `detected_at` (Timestamp)

## 4. Sécurité & Flux de Données
- **Authentification** : JWT via Supabase Auth.
- **Autorisation** : RLS (Row Level Security) dans PostgreSQL pour garantir que chaque utilisateur ne voit que ses données.
- **Données Sensibles** : Les données de calendrier sont chiffrées au repos (Postgres TDE).
