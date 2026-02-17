# ⚡ Quick Start Guide - SmartAgenda AI

Ce guide vous permet de démarrer rapidement selon votre objectif.

---

## 🎯 Scénarios Rapides

### 1️⃣ Je veux juste tester l'app (le plus rapide)

**Temps estimé : 5 minutes**

```powershell
# 1. Cloner le projet
git clone https://github.com/raphy-IA/SmartAgenda.git
cd SmartAgenda

# 2. Configuration Backend
cd backend
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt

# Créer le .env (copier .env.example et remplir vos clés)
cp .env.example .env
# Éditer .env avec vos clés Supabase et OpenAI

# 3. Démarrer le backend
uvicorn app.main:app --reload --port 8001

# 4. Dans un nouveau terminal : Lancer l'app mobile (Web)
cd ../mobile
flutter pub get
flutter run -d chrome
```

✅ **Résultat** : L'app s'ouvre dans Chrome, backend tourne sur http://localhost:8001

---

### 2️⃣ Je veux développer sur Android

**Temps estimé : 15 minutes**

**Prérequis** : Android Studio installé

```powershell
# 1-3. Même que scénario 1

# 4. Ouvrir Android Studio > AVD Manager
# Créer un émulateur (Pixel 6 Pro, Android 13)
# Lancer l'émulateur

# 5. Lancer l'app sur l'émulateur
cd mobile
flutter run
```

✅ **Résultat** : L'app tourne sur l'émulateur Android

---

### 3️⃣ Je veux tester sur mon téléphone

**Temps estimé : 10 minutes**

```powershell
# 1-3. Même que scénario 1

# 4. Sur votre téléphone Android
# - Activer le mode développeur (Paramètres > À propos > Taper 7 fois sur "Numéro de build")
# - Activer le débogage USB
# - Connecter le téléphone via USB

# 5. Modifier l'URL de l'API pour utiliser l'IP de votre PC
# Dans mobile/lib/features/voice/data/repositories/voice_repository.dart
# Remplacer "127.0.0.1" par l'IP de votre PC (ex: "192.168.1.100")

# 6. Trouver l'IP de votre PC
ipconfig  # Chercher "Adresse IPv4"

# 7. Lancer sur le device
cd mobile
flutter devices  # Voir votre téléphone listé
flutter run -d <device-id>
```

✅ **Résultat** : L'app s'installe et tourne sur votre téléphone

---

### 4️⃣ Je veux déployer en production (Backend)

**Temps estimé : 30 minutes**

**Prérequis** : Un VPS Linux avec accès SSH

```bash
# Sur votre VPS

# 1. Installer Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 2. Cloner le projet
git clone https://github.com/raphy-IA/SmartAgenda.git
cd SmartAgenda/backend

# 3. Configurer .env (production)
nano .env
# Remplir avec vos clés de PRODUCTION

# 4. Build et lancer
sudo docker build -t smartagenda-backend .
sudo docker run -d -p 80:8000 --name api --env-file .env --restart always smartagenda-backend

# 5. (Optionnel mais recommandé) Configurer HTTPS
sudo apt install nginx certbot python3-certbot-nginx -y
# Suivre le guide complet pour la configuration Nginx + SSL
```

✅ **Résultat** : Backend accessible sur http://votre-ip-vps (ou https://votre-domaine.com)

---

### 5️⃣ Je veux compiler l'APK pour distribuer

**Temps estimé : 10 minutes**

```powershell
# 1. Modifier l'URL de l'API vers production
# Dans mobile/lib/features/*/data/repositories/*_repository.dart
# Remplacer "http://127.0.0.1:8001" par "https://votre-domaine.com"

# 2. Build de l'APK
cd mobile
flutter build apk --release

# 3. Récupérer l'APK
# Fichier généré : mobile/build/app/outputs/flutter-apk/app-release.apk
```

✅ **Résultat** : APK prêt à être installé sur n'importe quel téléphone Android

---

### 6️⃣ Je veux utiliser GitHub Actions pour auto-build

**Temps estimé : 2 minutes**

Le projet inclut déjà un workflow GitHub Actions !

```bash
# 1. Push sur la branche main
git add .
git commit -m "Update app"
git push origin main

# 2. Aller sur GitHub > Actions
# L'APK sera automatiquement compilé

# 3. Télécharger l'APK
# Actions > Workflow run > Artifacts > app-release
```

✅ **Résultat** : APK compilé automatiquement à chaque push

---

## 🛠️ Commandes Utiles

### Backend

```powershell
# Démarrer le backend
uvicorn app.main:app --reload --port 8001

# Voir les logs
# Les logs s'affichent directement dans le terminal

# Tester l'API
curl http://localhost:8001/health
# OU ouvrir http://localhost:8001/docs dans le navigateur
```

### Mobile

```powershell
# Lister les devices disponibles
flutter devices

# Lancer sur un device spécifique
flutter run -d <device-id>

# Lancer sur Chrome
flutter run -d chrome

# Hot reload (dans l'app qui tourne)
# Appuyez sur 'r' dans le terminal

# Hot restart complet
# Appuyez sur 'R' dans le terminal

# Nettoyer le cache
flutter clean
flutter pub get

# Build APK
flutter build apk --release
```

### Docker (Backend)

```bash
# Build de l'image
docker build -t smartagenda-backend .

# Lancer le conteneur
docker run -d -p 8001:8000 --name api --env-file .env smartagenda-backend

# Voir les logs
docker logs api

# Arrêter le conteneur
docker stop api

# Supprimer le conteneur
docker rm api

# Relancer après modification
docker stop api && docker rm api && docker build -t smartagenda-backend . && docker run -d -p 8001:8000 --name api --env-file .env smartagenda-backend
```

---

## 🔍 Résolution de Problèmes Express

### ❌ "Target of URI doesn't exist"
```powershell
flutter pub get
```

### ❌ Backend ne démarre pas (port occupé)
```powershell
# Trouver le processus sur le port 8001
netstat -ano | findstr :8001

# Tuer le processus
taskkill /PID <PID> /F
```

### ❌ Flutter ne trouve pas mon téléphone
```powershell
# Vérifier les drivers USB
flutter doctor

# Réautoriser le débogage USB sur le téléphone
# Déconnectez et reconnectez le cable
```

### ❌ L'app ne se connecte pas au backend (sur device physique)
- Vérifiez que le téléphone et le PC sont sur le même réseau WiFi
- Remplacez `127.0.0.1` par l'IP locale de votre PC (`ipconfig`)
- Vérifiez que le firewall Windows autorise le port 8001

---

## 📚 Documentation Complète

Pour plus de détails, consultez les guides complets :

- **[Guide de Configuration - Mode Développement](01_development_setup.md)** : Installation détaillée, toutes les options de dev
- **[Guide de Déploiement Production](02_production_deployment.md)** : VPS, HTTPS, App Stores, CI/CD
- **[Architecture Technique](../technical_architecture.md)** : Comprendre le code
- **[Logique IA](../ai_logic.md)** : Comment fonctionne l'intelligence artificielle
- **[Roadmap](../roadmap.md)** : Fonctionnalités à venir

---

## 💡 Conseils Pro

### Pour le développement
- Utilisez **Flutter Web** (`flutter run -d chrome`) pour le développement rapide de l'UI
- Utilisez **Android Emulator** pour tester les fonctionnalités natives (microphone, etc.)
- Gardez le backend en mode `--reload` pour les modifications rapides

### Pour la production
- Créez une branche `production` séparée avec les URLs de production
- Testez toujours sur un device physique avant de publier
- Utilisez GitHub Actions pour automatiser les builds
- Configurez HTTPS pour votre backend (obligatoire pour une vraie app)

### Workflow recommandé
1. **Backend** → Démarrer en premier
2. **Mobile Web** → Développer l'UI rapidement
3. **Émulateur/Device** → Tester les fonctionnalités natives
4. **Build & Deploy** → Une fois satisfait

---

## 🎯 Prochaines Étapes

Une fois que vous avez testé en local :

1. ✅ **Configurez votre backend en production** (VPS ou Heroku)
2. ✅ **Créez une keystore pour signer votre app** Android
3. ✅ **Configurez GitHub Actions** pour l'auto-build
4. ✅ **Créez vos comptes développeur** (Google Play / App Store)
5. ✅ **Publiez votre app** ! 🚀

---

**Besoin d'aide ?** Consultez les guides détaillés ou la documentation du projet.
