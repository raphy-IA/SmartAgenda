# SmartAgenda AI 🚀

**SmartAgenda AI** est un assistant personnel intelligent conçu pour optimiser la gestion du temps grâce à l'automatisation, la priorisation contextuelle et une interaction naturelle (Vocale & UI).

## 📂 Documentation (Source de Vérité)

Toute la configuration, l'architecture et les guides sont centralisés ici :
👉 **[MASTER_DEVELOPER_GUIDE.md](MASTER_DEVELOPER_GUIDE.md)**

### Accès rapides :
- [⚡ Cheat Sheet de commandes](docs/documentation-eleve/commandes%20à%20lancer.md)
- [🏗 Architecture Technique](docs/technical_architecture.md)
- [🧠 Logique IA](docs/ai_logic.md)
- [🔧 Migration Supabase](supabase_migration.sql)

---

## 🛠 Architecture Technique
- **Mobile** : Flutter (iOS/Android)
- **Backend IA** : Python FastAPI (Docker sur VPS)
- **Base de Données** : Supabase (PostgreSQL)
- **IA** : LLM (Groq/Gemini) + Moteur de règles

## 🚀 Démarrage Rapide

### 1. Développement Local
Consultez le [Master Developer Guide](MASTER_DEVELOPER_GUIDE.md#💻-environnement-local-développement) pour configurer votre environnement Python et Flutter.

### 2. Déploiement VPS
Le projet utilise Docker Compose pour un déploiement simplifié sur votre serveur.
Commandes de mise à jour :
```bash
git pull origin main
docker compose up -d --build backend
```

---
*Projet développé par Sheila & Raphy AI.*
