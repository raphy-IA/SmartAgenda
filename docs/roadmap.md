# Roadmap de Développement - SmartAgenda AI

## Phase 1 : MVP (Mois 1 à 3)
*Goal : Lancer une application utilisable avec les fonctions "Core" et une "Smart Touch".*

**Mois 1 : Fondations**
- [ ] Setup Infrastructure (Supabase, FastAPI, CI/CD).
- [ ] Auth & User Profile (Préférences de base).
- [ ] CRUD Événements (API + App Mobile basique).
- [ ] Modèle de données Cal/Event/Category.

**Mois 2 : Intelligence & Notifications (Boosté)**
- [ ] Moteur de Notifications (Cron jobs + Push FCM).
- [ ] Algorithme de détection de conflit (Alerte simple).
- [ ] **Chronobiologie** : Implémentation basique des profils "Matin/Soir".
- [ ] **Météo/Trafic** : Connexion API (OpenWeather + Google Maps).

**Mois 3 : Polish & Release**
- [ ] **Anti-Burnout** : Règles de blocage simple (>10h).
- [ ] **Prep Mode** : Digest matinal enrichi.
- [ ] UI/UX "Premium" (Dark mode, Animations).
- [ ] Déploiement Stores.

## Phase 2 : V2 - "Ecosystem & Social" (Mois 4 à 6)
*Goal : Expansion vers l'extérieur.*

- **Smart Booking** : Liens "Intimes" (Calendly killer) complets.
- **Mode Freeze** : Version avancée avec réponses auto aux emails.
- **LLM Integration** : Parsing naturel complexe.

## Phase 3 : V3 - "Ecosystem & Analytics" (Mois 6+)
*Goal : Expansion et Analyse.*

- **Rapports Hebdo** : Analytics comportementaux (Temps passé, équilibre vie pro/perso).
- **Intégrations** : Sync bi-directionnelle Google Calendar / Outlook.
- **Version Web** : Dashboard complet sur Desktop (Next.js).
- **Social** : Partage de disponibilités.

## Estimation Ressources (MVP)
- **1 Dev Mobile (Flutter)** : UI, State Management, Intégration API.
- **1 Dev Backend/AI (Python)** : API, DB Arch, Logic AI, Prompt Engineering.
