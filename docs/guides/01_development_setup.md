# 🛠️ Guide de Configuration - Mode Développement

Ce guide couvre toutes les options pour développer et tester SmartAgenda AI en local.

---

## 📋 Prérequis Système

### Outils Obligatoires
- **Git** : [Télécharger Git](https://git-scm.com/)
- **Python 3.9+** : [Télécharger Python](https://www.python.org/)
- **Flutter 3.2+** : [Télécharger Flutter](https://flutter.dev/)
- **Node.js** (optionnel, pour scripts) : [Télécharger Node.js](https://nodejs.org/)

### Éditeurs Recommandés
- **VS Code** avec extensions :
  - Python
  - Flutter
  - Dart
  - GitLens
- **Android Studio** (pour développement mobile Android)
- **Xcode** (pour développement iOS, macOS uniquement)

---

## 🚀 Installation Initiale

### 1. Cloner le Projet

```powershell
# Cloner le dépôt
git clone https://github.com/raphy-IA/SmartAgenda.git
cd SmartAgenda
```

### 2. Configuration du Backend

```powershell
# Naviguer vers le dossier backend
cd backend

# Créer un environnement virtuel Python
python -m venv venv

# Activer l'environnement virtuel
.\venv\Scripts\Activate.ps1  # Windows PowerShell
# OU
source venv/bin/activate      # Linux/macOS

# Installer les dépendances
pip install -r requirements.txt
```

### 3. Configuration des Variables d'Environnement

Créer un fichier `.env` dans le dossier `backend/` :

```bash
# Copier le fichier exemple
cp .env.example .env
```

Éditer le fichier `.env` avec vos clés :

```env
# FastAPI
PROJECT_NAME=SmartAgenda AI API

# Supabase
SUPABASE_URL=https://votre-projet.supabase.co
SUPABASE_KEY=votre-anon-key

# OpenAI (ou Gemini)
OPENAI_API_KEY=sk-votre-cle
GEMINI_API_KEY=votre-cle-gemini  # Si vous utilisez Gemini

# GROQ (optionnel, pour vocale)
GROQ_API_KEY=votre-cle-groq
```

### 4. Configuration du Mobile

```powershell
# Naviguer vers le dossier mobile
cd ../mobile

# Installer les dépendances Flutter
flutter pub get

# Vérifier la configuration Flutter
flutter doctor
```

> **Note** : Si `flutter doctor` signale des problèmes, suivez les instructions pour installer les SDK manquants.

---

## 💻 Options de Développement

### Option 1 : Développement Web (Flutter Web)

Le moyen le plus rapide pour tester l'interface sans émulateur.

```powershell
# Dans le dossier mobile/
flutter run -d chrome

# OU pour un autre navigateur
flutter run -d edge
```

**Avantages** :
- ✅ Rapide à démarrer
- ✅ Hot reload instantané
- ✅ Pas besoin d'émulateur

**Limitations** :
- ⚠️ Certaines fonctionnalités natives (speech-to-text) peuvent ne pas fonctionner

---

### Option 2 : Émulateur Android (Android Studio)

Pour tester les fonctionnalités natives complètes.

#### Installation
1. Installer **Android Studio** : [Télécharger](https://developer.android.com/studio)
2. Ouvrir **AVD Manager** (Android Virtual Device Manager)
3. Créer un nouvel appareil virtuel :
   - Device : Pixel 6 Pro (recommandé)
   - System Image : Android 13 (API 33) ou supérieur
   - RAM : 4096 MB minimum

#### Lancer l'émulateur

```powershell
# Lister les émulateurs disponibles
flutter emulators

# Lancer un émulateur spécifique
flutter emulators --launch <emulator_id>

# OU depuis Android Studio : AVD Manager > Play button
```

#### Lancer l'application

```powershell
# Dans le dossier mobile/
flutter run

# Flutter va automatiquement détecter l'émulateur lancé
```

**Avantages** :
- ✅ Toutes les fonctionnalités natives fonctionnent
- ✅ Simule un vrai téléphone Android
- ✅ Hot reload

**Limitations** :
- ⚠️ Consomme beaucoup de RAM (4-8 GB)
- ⚠️ Plus lent que Flutter Web

---

### Option 3 : Device Physique (Téléphone/Tablette)

Pour tester sur un vrai appareil.

#### Android

1. **Activer le mode développeur** sur votre téléphone :
   - Paramètres > À propos du téléphone
   - Appuyez 7 fois sur "Numéro de build"
   - Retournez dans Paramètres > Options pour développeurs
   - Activez "Débogage USB"

2. **Connecter le téléphone via USB**

3. **Vérifier la connexion** :

```powershell
# Lister les appareils connectés
flutter devices

# Vous devriez voir votre téléphone listé
```

4. **Lancer l'application** :

```powershell
flutter run -d <device_id>
```

#### iOS (macOS uniquement)

1. **Connecter votre iPhone/iPad**
2. **Configurer le provisioning profile** dans Xcode
3. **Lancer** :

```powershell
flutter run -d <device_id>
```

**Avantages** :
- ✅ Test sur matériel réel
- ✅ Performance native
- ✅ Accès à toutes les fonctionnalités (GPS, microphone, etc.)

---

### Option 4 : iOS Simulator (macOS uniquement)

```powershell
# Ouvrir le simulateur iOS
open -a Simulator

# Lancer l'application
flutter run -d "iPhone 15 Pro"
```

---

## 🔧 Lancement du Backend

### Mode Développement (Hot Reload)

```powershell
# Dans le dossier backend/
uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

Le backend sera accessible sur :
- API : http://localhost:8001
- Documentation Swagger : http://localhost:8001/docs
- Health check : http://localhost:8001/health

### Mode Production (Docker)

```powershell
# À la racine du projet
docker-compose up --build

# OU en arrière-plan
docker-compose up -d
```

---

## 🧪 Tests et Débogage

### Tests Unitaires Backend

```powershell
# Dans le dossier backend/
pytest

# Avec couverture de code
pytest --cov=app
```

### Tests d'Intégration

```powershell
# Scripts de test existants
python tests/test_flow.py
python tests/reproduce_conflict.py
```

### Tests Flutter

```powershell
# Dans le dossier mobile/
flutter test

# Tests d'intégration
flutter test integration_test/
```

### Debug avec VS Code

Créer `.vscode/launch.json` :

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter: Debug on Chrome",
      "request": "launch",
      "type": "dart",
      "deviceId": "chrome"
    },
    {
      "name": "Flutter: Debug on Android",
      "request": "launch",
      "type": "dart"
    },
    {
      "name": "Python: FastAPI",
      "type": "python",
      "request": "launch",
      "module": "uvicorn",
      "args": [
        "app.main:app",
        "--reload",
        "--port",
        "8001"
      ],
      "cwd": "${workspaceFolder}/backend"
    }
  ]
}
```

---

## 🔍 Commandes Utiles

### Flutter

```powershell
# Vérifier l'état de Flutter
flutter doctor -v

# Nettoyer le cache
flutter clean

# Lister les devices
flutter devices

# Hot reload manuel (dans l'app qui tourne)
# Appuyez sur 'r' dans le terminal

# Hot restart complet
# Appuyez sur 'R' dans le terminal

# Build pour debug
flutter build apk --debug
```

### Backend

```powershell
# Vérifier les dépendances
pip list

# Mettre à jour les dépendances
pip install --upgrade -r requirements.txt

# Vérifier le code avec flake8
flake8 app/

# Formater le code avec black
black app/
```

---

## 📱 Configuration des URLs API

### Pour le développement local

Les fichiers suivants contiennent l'URL du backend :

- `mobile/lib/features/voice/data/repositories/voice_repository.dart`
- `mobile/lib/features/events/data/repositories/event_repository.dart`
- `mobile/lib/features/events/data/repositories/category_repository.dart`

**Configuration pour développement local** :

```dart
final String baseUrl = "http://127.0.0.1:8001/api/v1";
```

> **Note** : Si vous testez sur un device physique, remplacez `127.0.0.1` par l'IP de votre PC sur le réseau local (ex: `http://192.168.1.10:8001/api/v1`)

---

## 🚨 Résolution de Problèmes Courants

### "Target of URI doesn't exist"
```powershell
flutter pub get
```

### Backend ne démarre pas
```powershell
# Vérifier que le port 8001 n'est pas occupé
netstat -ano | findstr :8001

# Si occupé, tuer le processus
taskkill /PID <PID> /F
```

### Flutter doctor signale des erreurs
- **Android SDK manquant** : Installer via Android Studio
- **Xcode manquant** : Installer via App Store (macOS)
- **Licences Android non acceptées** : `flutter doctor --android-licenses`

---

## 🎯 Workflow Recommandé

1. **Démarrer le backend** : `uvicorn app.main:app --reload --port 8001`
2. **Démarrer l'app mobile** : `flutter run -d chrome` (ou émulateur)
3. **Modifier le code** : Les deux supportent le hot reload
4. **Tester** : Utiliser l'app et vérifier les logs dans les deux terminaux
5. **Commit** : `git add . && git commit -m "votre message"`

---

## 📚 Ressources Supplémentaires

- [Documentation Flutter](https://flutter.dev/docs)
- [Documentation FastAPI](https://fastapi.tiangolo.com/)
- [Documentation Supabase](https://supabase.com/docs)
- [Guide AI/LLM Integration](../ai_logic.md)

---

**Prochain guide** : [Guide de Déploiement Production](02_production_deployment.md)
