# 🚀 Guide de Déploiement Production

Ce guide couvre toutes les options pour déployer SmartAgenda AI en production.

---

## 📋 Table des Matières

1. [Déploiement du Backend](#1-déploiement-du-backend)
2. [Compilation de l'Application Mobile](#2-compilation-de-lapplication-mobile)
3. [Publication sur les App Stores](#3-publication-sur-les-app-stores)
4. [Automatisation avec GitHub Actions](#4-automatisation-avec-github-actions)
5. [Configuration Production](#5-configuration-production)

---

## 1. Déploiement du Backend

### Option 1 : VPS avec Docker (Recommandé)

Le déploiement le plus simple et robuste pour un backend FastAPI.

#### Prérequis
- Un VPS Linux (Ubuntu 20.04+ recommandé)
- Accès SSH root ou sudo
- Nom de domaine (optionnel mais recommandé)

#### Installation sur le VPS

**1. Connexion au VPS**
```bash
ssh root@votre-ip-vps
```

**2. Installation de Docker**
```bash
# Mise à jour du système
sudo apt update && sudo apt upgrade -y

# Installation de Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Vérification
docker --version
```

**3. Installation de Docker Compose**
```bash
sudo apt install docker-compose -y
```

**4. Clonage du projet**
```bash
# Installer Git si nécessaire
sudo apt install git -y

# Cloner le dépôt
git clone https://github.com/raphy-IA/SmartAgenda.git
cd SmartAgenda/backend
```

**5. Configuration de l'environnement**
```bash
# Créer le fichier .env
nano .env
```

Contenu du fichier `.env` (production) :
```env
# FastAPI
PROJECT_NAME=SmartAgenda AI API
API_V1_STR=/api/v1

# Supabase
SUPABASE_URL=https://votre-projet.supabase.co
SUPABASE_KEY=votre-service-role-key  # ⚠️ Utilisez la service role key, pas l'anon key

# OpenAI
OPENAI_API_KEY=sk-votre-cle-production

# Gemini (optionnel)
GEMINI_API_KEY=votre-cle-gemini

# GROQ (pour transcription vocale)
GROQ_API_KEY=votre-cle-groq

# Security
SECRET_KEY=votre-secret-key-super-securise  # Générez avec: openssl rand -hex 32
```

**6. Build et lancement du conteneur**
```bash
# Build de l'image Docker
sudo docker build -t smartagenda-backend .

# Lancement du conteneur
sudo docker run -d \
  -p 80:8000 \
  --name smartagenda-api \
  --env-file .env \
  --restart always \
  smartagenda-backend
```

**7. Vérification**
```bash
# Vérifier que le conteneur tourne
sudo docker ps

# Vérifier les logs
sudo docker logs smartagenda-api

# Tester l'API
curl http://votre-ip-vps/health
```

Votre API est maintenant accessible sur `http://votre-ip-vps`

---

#### Configuration HTTPS avec Nginx + Certbot

Pour sécuriser votre API avec HTTPS (obligatoire en production) :

**1. Installer Nginx**
```bash
sudo apt install nginx -y
```

**2. Configurer Nginx comme reverse proxy**
```bash
sudo nano /etc/nginx/sites-available/smartagenda
```

Contenu :
```nginx
server {
    listen 80;
    server_name votre-domaine.com;  # Remplacez par votre domaine

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**3. Activer la configuration**
```bash
sudo ln -s /etc/nginx/sites-available/smartagenda /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

**4. Installer Certbot pour SSL**
```bash
sudo apt install certbot python3-certbot-nginx -y

# Générer le certificat SSL
sudo certbot --nginx -d votre-domaine.com

# Le certificat se renouvellera automatiquement
```

Votre API est maintenant accessible sur `https://votre-domaine.com` 🎉

---

### Option 2 : Heroku (Plus simple, payant)

**1. Installation de Heroku CLI**
```bash
# Windows
choco install heroku-cli

# macOS
brew tap heroku/brew && brew install heroku

# Linux
curl https://cli-assets.heroku.com/install.sh | sh
```

**2. Login et création de l'app**
```bash
heroku login
heroku create smartagenda-api
```

**3. Ajout des variables d'environnement**
```bash
heroku config:set SUPABASE_URL=https://...
heroku config:set SUPABASE_KEY=...
heroku config:set OPENAI_API_KEY=sk-...
```

**4. Création du Procfile**
Créer `backend/Procfile` :
```
web: uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

**5. Déploiement**
```bash
git subtree push --prefix backend heroku main

# OU si vous avez tout le projet
git push heroku main
```

---

### Option 3 : Cloud Platforms (AWS, GCP, Azure)

Consultez la documentation spécifique de chaque plateforme pour déployer un conteneur Docker.

---

## 2. Compilation de l'Application Mobile

### Préparation avant Build

**1. Modifier l'URL de l'API**

Dans les fichiers suivants, remplacez l'URL localhost par l'URL de votre backend en production :

- `mobile/lib/features/voice/data/repositories/voice_repository.dart`
- `mobile/lib/features/events/data/repositories/event_repository.dart`
- `mobile/lib/features/events/data/repositories/category_repository.dart`

**Avant** :
```dart
final String baseUrl = "http://127.0.0.1:8001/api/v1";
```

**Après** :
```dart
final String baseUrl = "https://votre-domaine.com/api/v1";
```

> ⚠️ **IMPORTANT** : N'oubliez pas de commit ces changements dans une branche `production` séparée.

---

### Build Android (APK/AAB)

#### Build APK (Pour distribution directe)

```powershell
# Dans le dossier mobile/
flutter build apk --release
```

Le fichier sera généré dans :
`mobile/build/app/outputs/flutter-apk/app-release.apk`

---

#### Build App Bundle (Pour Google Play Store)

```powershell
flutter build appbundle --release
```

Le fichier sera généré dans :
`mobile/build/app/outputs/bundle/release/app-release.aab`

---

#### Signature de l'Application (Obligatoire pour Production)

**1. Générer une keystore**

```powershell
# Dans le dossier mobile/android/
keytool -genkey -v -keystore smartagenda-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias smartagenda
```

Répondez aux questions :
- Mot de passe du keystore : **[GARDEZ-LE EN SÉCURITÉ]**
- Nom, organisation, etc.

**2. Configurer la signature**

Créer `mobile/android/key.properties` :
```properties
storePassword=votre-mot-de-passe
keyPassword=votre-mot-de-passe
keyAlias=smartagenda
storeFile=smartagenda-release-key.jks
```

**3. Modifier `mobile/android/app/build.gradle`**

Ajouter avant `android {` :
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Dans `android { ... }`, ajouter :
```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
        // ... autres configurations
    }
}
```

**4. Build signé**
```powershell
flutter build apk --release
# OU
flutter build appbundle --release
```

> ⚠️ **NE JAMAIS COMMIT** le fichier `key.properties` ou la keystore dans Git ! Ajoutez-les au `.gitignore`.

---

### Build iOS (IPA)

> **Prérequis** : macOS avec Xcode installé

**1. Configuration du provisioning profile**

- Ouvrir `mobile/ios/Runner.xcworkspace` dans Xcode
- Sélectionner l'équipe de développement
- Configurer le Bundle Identifier

**2. Build**

```bash
flutter build ios --release

# OU depuis Xcode
# Product > Archive
```

**3. Exportation IPA**

Dans Xcode :
- Window > Organizer
- Sélectionner l'archive
- Distribute App > App Store Connect

---

## 3. Publication sur les App Stores

### Google Play Store

**1. Créer un compte développeur**
- Aller sur [Google Play Console](https://play.google.com/console)
- Payer les frais uniques ($25)

**2. Créer une nouvelle application**
- Nom : SmartAgenda AI
- Langue par défaut : Français
- Type : Application

**3. Remplir les informations**
- Description courte et longue
- Captures d'écran (minimum 2, 1920x1080)
- Icône de l'application (512x512 PNG)
- Bannière (1024x500)

**4. Upload de l'AAB**
- Production > Créer une version
- Upload de `app-release.aab`
- Notes de version

**5. Soumission à la Review**

⏱️ La review prend généralement 1-3 jours.

---

### Apple App Store

**1. Créer un compte développeur Apple**
- Aller sur [Apple Developer](https://developer.apple.com/)
- Payer l'abonnement annuel ($99/an)

**2. App Store Connect**
- Créer une nouvelle app
- Remplir les métadonnées
- Upload des screenshots (différentes tailles pour iPhone/iPad)

**3. Upload via Xcode**
- Organizer > Upload to App Store

**4. Soumission à la Review**

⏱️ La review Apple peut prendre 24h à 7 jours.

---

## 4. Automatisation avec GitHub Actions

Le projet inclut déjà un workflow GitHub Actions pour automatiser la compilation de l'APK.

### Configuration actuelle

Fichier `.github/workflows/build_apk.yml` :

```yaml
name: Build Android APK

on:
  push:
    branches:
      - main
  workflow_dispatch:  # Permet de lancer manuellement

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '17'
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          flutter-version: '3.22.2'
      
      - name: Get Dependencies
        working-directory: ./mobile
        run: flutter pub get
      
      - name: Build APK (Release)
        working-directory: ./mobile
        run: flutter build apk --release
      
      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: app-release
          path: mobile/build/app/outputs/flutter-apk/app-release.apk
```

### Utilisation

**Method 1 : Push automatique**
```bash
git add .
git commit -m "Update app"
git push origin main
```

L'APK sera automatiquement compilé et disponible dans l'onglet **Actions** de GitHub.

**Method 2 : Lancement manuel**
1. Aller sur GitHub > Actions
2. Sélectionner "Build Android APK"
3. Cliquer sur "Run workflow"

---

### Ajout de Secrets pour la Signature Automatique

**1. Encoder la keystore en base64**
```bash
base64 -i smartagenda-release-key.jks | pbcopy  # macOS
# OU
base64 smartagenda-release-key.jks  # Linux/Windows
```

**2. Ajouter dans GitHub Secrets**
- Repository > Settings > Secrets and variables > Actions
- Ajouter :
  - `KEYSTORE_BASE64` : Le contenu encodé
  - `KEYSTORE_PASSWORD` : Votre mot de passe
  - `KEY_ALIAS` : smartagenda
  - `KEY_PASSWORD` : Votre mot de passe

**3. Modifier le workflow**

Ajouter avant le build :
```yaml
- name: Decode Keystore
  run: |
    echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/smartagenda-release-key.jks

- name: Create key.properties
  run: |
    echo "storePassword=${{ secrets.KEYSTORE_PASSWORD }}" > android/key.properties
    echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
    echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
    echo "storeFile=smartagenda-release-key.jks" >> android/key.properties
  working-directory: ./mobile
```

---

## 5. Configuration Production

### Environnements Séparés

Il est recommandé d'avoir deux environnements :

**Development** :
- Backend : http://localhost:8001
- Base de données : Supabase dev project
- API Keys : Clés de test

**Production** :
- Backend : https://api.votre-domaine.com
- Base de données : Supabase production project
- API Keys : Clés de production

### Gestion des Configurations

Créer un fichier `mobile/lib/core/config/env_config.dart` :

```dart
class EnvConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  
  static String get apiBaseUrl {
    return isProduction 
      ? 'https://api.votre-domaine.com/api/v1'
      : 'http://127.0.0.1:8001/api/v1';
  }
}
```

Utiliser dans les repositories :
```dart
final String baseUrl = EnvConfig.apiBaseUrl;
```

Build avec l'environnement :
```bash
flutter build apk --release  # isProduction = true automatiquement
flutter run  # isProduction = false
```

---

## 🔍 Checklist de Déploiement

### Backend
- [ ] Variables d'environnement configurées
- [ ] HTTPS activé (avec certificat SSL)
- [ ] Firewall configuré (ports 80, 443, 22)
- [ ] Backups de la base de données activés
- [ ] Monitoring configuré (logs, uptime)
- [ ] Rate limiting implémenté

### Mobile
- [ ] URLs API mises à jour vers production
- [ ] Application signée avec une keystore production
- [ ] Icône et splash screen configurés
- [ ] Permissions Android/iOS correctement déclarées
- [ ] Tests sur devices physiques effectués
- [ ] Version number et build number incrémentés

### App Stores
- [ ] Compte développeur créé
- [ ] Métadonnées remplies (description, screenshots)
- [ ] Politique de confidentialité rédigée
- [ ] Compliance RGPD/Privacy vérifiée

---

## 📚 Ressources

- [Flutter Deployment Documentation](https://flutter.dev/docs/deployment)
- [FastAPI Deployment Guide](https://fastapi.tiangolo.com/deployment/)
- [Google Play Console](https://play.google.com/console)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

**Guide précédent** : [Guide de Configuration - Mode Développement](01_development_setup.md)
**Guide suivant** : [Guide de Maintenance et Monitoring](03_maintenance_monitoring.md)
