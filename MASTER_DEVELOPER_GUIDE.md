# 📔 SmartAgenda AI - Master Developer Guide

Ce guide centralise toute la configuration et les procédures pour le projet SmartAgenda AI.

## 🏗 Architecture du Projet

Le système est composé de trois briques principales :
1.  **Mobile (Flutter)** : Interface utilisateur (Android/Web).
2.  **IA Backend (Python FastAPI)** : Le "cerveau" qui traite la voix et gère la logique métier.
3.  **Base de Données (Supabase)** : Stockage persistant des événements et authentification.

---

## 🚩 CONFIGURATION STABLE & VALIDÉE (NE PAS MODIFIER)

> [!CAUTION]
> Ces paramètres ont été testés après plusieurs erreurs de réseau. **Toute modification peut casser la connexion mobile.**

| Paramètre | Valeur Validée | Pourquoi ? |
| :--- | :--- | :--- |
| **IP VPS (vpsUrl)** | `148.230.80.83` | L'IPv4 est plus universelle que l'IPv6 pour Android. |
| **Binding Docker** | `--host 0.0.0.0` | Permet le pontage réseau correct sur Hostinger. (Pas de `::`). |
| **Port Externe** | `8001` | Ouvert dans le pare-feu du VPS et libre de tout conflit. |
| **Protocole** | `http://` | Android exige `usesCleartextTraffic="true"` dans le Manifest pour fonctionner. |

---

## 💻 Environnement Local (Développement)

### 1. Backend IA
Le backend doit tourner pour que le micro et l'IA fonctionnent.
- **Dossier** : `backend/`
- **Commandes** :
  ```powershell
  # 1. Activer l'environnement (depuis la racine du projet)
  .\venv\Scripts\Activate.ps1
  
  # 2. Lancer le serveur
  cd backend
  uvicorn app.main:app --reload --port 8001
  ```
- **Lien local** : `http://localhost:8001`

### 2. Application Mobile
- **Dossier** : `mobile/`
- **Lancer localement** :
  - Sur Chrome : `flutter run -d chrome`
  - Sur Android (USB/Simulateur) : `flutter run -d android`
- **Générer l'APK localement** :
  ```bash
  cd mobile
  flutter build apk --release
  ```
  *L'APK sera dans : `build/app/outputs/flutter-apk/app-release.apk`*

- **Configuration API** : Se gère dans `lib/core/config/api_config.dart`.

---

## 📲 Transfert et Installation de l'APK

Il existe des méthodes plus rapides que Google Drive :

### 1. Installation directe (Recommandé - USB)
Si votre téléphone est branché en USB à votre PC :
```bash
cd mobile
flutter install
```
*Cette commande prend l'APK déjà construit et l'installe directement sur le téléphone.*

### 2. Transfert par réseau local (Sans câble)
Si vous ne voulez pas de câble, lancez un mini-serveur sur votre PC :
1. Dans le dossier où se trouve l'APK, tapez : `python -m http.server 8080`
2. Sur votre téléphone, allez sur `http://IP-DE-VOTRE-PC:8080`
3. Cliquez sur l'APK pour l'installer.

---

## 🌐 Environnement Distant (Production)

### 1. Supabase (Base de Données)
- **Colonnes obligatoires** (Table `events`) : `status` (TEXT), `metadata` (JSONB).
- **Migration** : Exécuter `supabase_migration.sql` dans le SQL Editor de Supabase si ces champs manquent.

### 2. VPS Backend (Docker)
Le backend est hébergé sur un VPS Linux et tourne via Docker pour une stabilité maximale.
- **IP VPS** : `2a02:4780:2d:a183::1` (Port 8001)
- **Mise à jour du serveur** :
  ```bash
  ssh raphyai82@votre-ip
  cd /home/raphyai82/apps/SmartAgenda/SmartAgenda
  git pull origin main
  docker compose up -d --build backend
  ```

---

## 🔧 Opérations Courantes

### Mettre à jour l'IA et l'Application
1.  Faites vos modifications de code localement.
2.  Poussez sur GitHub : `git add . ; git commit -m "Description" ; git push`.
3.  **Sur le VPS** : Lancez le `docker compose` cité plus haut.
4.  **Sur GitHub (Générer l'APK)** :
    - Allez dans l'onglet **Actions**.
    - Cliquez sur **"Build Android APK"** dans la barre latérale gauche.
    - Cliquez sur le bouton **"Run workflow"** (en haut à droite).
    - Une fois terminé, téléchargez l'APK dans la section **Artifacts**.

### Débogage
- **Logs local** : Regardez le terminal où tourne `uvicorn`.
- **Logs VPS** : `docker logs -f smartagenda_backend`.
- **Vérifier les ports** : `sudo netstat -tulpn | grep LISTEN`.

---

## 📝 Configuration des Clés (.env)
Le fichier `backend/.env` doit contenir :
- `GROQ_API_KEY` : Pour le parsing vocal rapide.
- `GOOGLE_API_KEY` : (Optionnel) Pour Gemini.
- `SUPABASE_URL` & `SUPABASE_KEY` : Clés de l'instance Supabase.
