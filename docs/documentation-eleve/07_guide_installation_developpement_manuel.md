# 🛠️ Guide Installation & Développement Manuel - SmartAgenda AI

## 📌 Introduction

Ce guide t'accompagne **pas à pas** pour installer tout l'environnement de développement et coder le projet SmartAgenda **manuellement**, sans assistance IA. C'est la méthode traditionnelle utilisée par les développeurs.

**Temps estimé** : ~4-6 heures pour l'installation et configuration  
**Niveau** : Débutant à Intermédiaire  
**Public** : Élève de 8ème année sans connaissance en programmation

> 💡 **Important** : Chaque étape explique **POURQUOI** on installe quelque chose et **À QUOI ça sert**. Même si tu ne comprends pas tout maintenant, ces explications t'aideront à présenter ton projet !

---

## 🧰 Vue d'Ensemble : Les Outils Nécessaires

Avant de commencer, comprends bien **quels outils** on va installer et **pourquoi** :

### 1. 🖊️ Visual Studio Code (VS Code)
**C'est quoi ?** Un éditeur de code (comme Word mais pour coder)  
**Pourquoi ?** Pour écrire et modifier ton code facilement  
**Analogie** : C'est ton "bureau de travail" où tu vas passer tout ton temps

### 2. 🐍 Python
**C'est quoi ?** Un langage de programmation  
**Pourquoi ?** Pour créer le serveur (backend) de SmartAgenda  
**Analogie** : C'est la langue que ton ordinateur va comprendre pour faire fonctionner le serveur

### 3. 📱 Flutter
**C'est quoi ?** Un framework pour créer des applications mobiles  
**Pourquoi ?** Pour créer l'application que tu vas utiliser sur ton téléphone  
**Analogie** : C'est la "boîte à outils" pour construire l'interface de ton app

### 4. 📦 Git
**C'est quoi ?** Un système de sauvegarde de code  
**Pourquoi ?** Pour garder l'historique de toutes tes modifications  
**Analogie** : C'est comme un "CTRL+Z géant" qui garde toutes les versions de ton projet

### 5. 🤖 Android Studio
**C'est quoi ?** Un logiciel pour développer sur Android  
**Pourquoi ?** Pour tester ton app sur un téléphone virtuel (émulateur)  
**Analogie** : C'est un "téléphone virtuel" dans ton ordinateur pour tester l'app

### 6. 🐳 Docker (Optionnel)
**C'est quoi ?** Un système pour "empaqueter" ton application  
**Pourquoi ?** Pour que ton app fonctionne de la même façon partout  
**Analogie** : C'est une "boîte de transport" qui garantit que ton app marche sur n'importe quel ordinateur

### 7. 🗄️ PostgreSQL (En ligne via Supabase)
**C'est quoi ?** Une base de données  
**Pourquoi ?** Pour stocker tous les rendez-vous et informations  
**Analogie** : C'est le "classeur géant" où toutes les informations sont rangées

---

## 🎯 PARTIE 1 : Installation de l'Environnement

### Étape 1.1 : Installer Visual Studio Code

#### 💡 Pourquoi Visual Studio Code ?

**C'est ton espace de travail principal !**

Imagine que tu veux écrire un livre. Tu pourrais utiliser :
- ❌ Le Bloc-notes (trop simple, pas pratique)
- ✅ Word (formatage, corrections, outils)

Pour le code, c'est pareil :
- ❌ Bloc-notes : pas d'aide, pas de couleurs
- ✅ **VS Code** : 
  - Coloration du code (pour mieux lire)
  - Autocomplétion (suggestions)
  - Détection d'erreurs en temps réel
  - Extensions pour ajouter des fonctionnalités

**Objectif de cette étape** : Avoir un éditeur de code professionnel et gratuit

#### A. Téléchargement

1. **Aller sur** : https://code.visualstudio.com/
2. **Cliquer** sur "Download for Windows"
3. **Exécuter** le fichier téléchargé `VSCodeUserSetup-x64-1.x.x.exe`
4. **Suivre** l'assistant d'installation :
   - ✅ Cocher "Add to PATH"
   - ✅ Cocher "Create desktop icon"
   - ✅ Cocher "Register Code as an editor for supported file types"

#### B. Premier Lancement

1. **Ouvrir** VS Code
2. **Interface** : Familiarise-toi avec les zones :
   - 📁 **Explorer** (gauche) : Arborescence des fichiers
   - ✏️ **Éditeur** (centre) : Zone de code
   - 🔍 **Recherche** (gauche) : Rechercher dans les fichiers
   - 🧩 **Extensions** (gauche) : Installer des plugins

---

### Étape 1.2 : Installer les Extensions VS Code Essentielles

#### 💡 Pourquoi des Extensions ?

**Les extensions = Super-pouvoirs pour VS Code !**

**Analogie** : C'est comme les applications sur ton téléphone :
- Téléphone de base : appels et SMS
- Avec apps : photos, jeux, musique, navigation...

VS Code de base : éditer du texte  
VS Code avec extensions : comprendre Python, Flutter, détecter erreurs, suggérer du code...

**Objectif** : Transformer VS Code en IDE (Integrated Development Environment) complet pour SmartAgenda

#### A. Extensions Générales

**Comment installer une extension :**
1. Cliquer sur l'icône Extensions (carré avec 4 petits carrés) ou `Ctrl+Shift+X`
2. Rechercher le nom de l'extension
3. Cliquer sur "Install"

**Extensions à installer :**

| Extension | Identifiant | Utilité |
|-----------|-------------|---------|
| **Python** | ms-python.python | Support Python complet |
| **Pylance** | ms-python.vscode-pylance | IntelliSense Python avancé |
| **Flutter** | Dart-Code.flutter | Support Flutter/Dart |
| **Dart** | Dart-Code.dart-code | Langage Dart |
| **Docker** | ms-azuretools.vscode-docker | Gestion containers |
| **REST Client** | humao.rest-client | Tester les API |
| **GitLens** | eamodio.gitlens | Git amélioré |
| **Better Comments** | aaron-bond.better-comments | Commentaires colorés |
| **Markdown All in One** | yzhang.markdown-all-in-one | Édition Markdown |
| **Error Lens** | usernamehw.errorlens | Erreurs inline |

#### B. Extensions Thème et Productivité

| Extension | Pour quoi ? |
|-----------|-------------|
| **Material Icon Theme** | Icônes de fichiers jolies |
| **One Dark Pro** | Thème sombre élégant |
| **Indent Rainbow** | Indentation colorée |
| **Bracket Pair Colorizer 2** | Parenthèses colorées |

**Installation rapide de toutes les extensions essentielles :**

```bash
# Copie cette commande dans le terminal VS Code (Ctrl+`)
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code
code --install-extension ms-azuretools.vscode-docker
code --install-extension humao.rest-client
code --install-extension eamodio.gitlens
code --install-extension aaron-bond.better-comments
code --install-extension yzhang.markdown-all-in-one
code --install-extension usernamehw.errorlens
```

---

### Étape 1.3 : Installer Python

#### 💡 Pourquoi Python ?

**Python = Le cerveau de ton serveur (backend)**

**Ce que Python fait dans SmartAgenda** :
- 📊 Gère la base de données (crée, lit, modifie, supprime les rendez-vous)
- 🧠 Fait tourner l'intelligence artificielle (détection conflits, priorités)
- 🔗 Crée l'API (le "serveur" qui répond aux demandes de l'app mobile)
- ⏰ Gère les rappels et notifications

**Pourquoi Python et pas un autre langage ?**
- ✅ Facile à lire (ressemble presque à de l'anglais)
- ✅ Excellent pour l'IA (beaucoup de bibliothèques)
- ✅ Très utilisé professionnellement
- ✅ Gratuit et open-source

**Objectif** : Pouvoir exécuter du code Python sur ton ordinateur

#### A. Téléchargement et Installation

1. **Aller sur** : https://www.python.org/downloads/
2. **Télécharger** Python 3.11.x (version stable)
3. **Exécuter** l'installateur
4. **⚠️ IMPORTANT** : Cocher "Add Python to PATH" avant de cliquer Install

#### B. Vérification

Ouvrir **PowerShell** ou **Terminal** et taper :

```bash
python --version
# Résultat attendu : Python 3.11.x

pip --version
# Résultat attendu : pip 23.x.x
```

#### C. Mettre à Jour pip

```bash
python -m pip install --upgrade pip
```

---

### Étape 1.4 : Installer Flutter SDK

#### 💡 Pourquoi Flutter ?

**Flutter = La boîte à outils pour créer ton app mobile**

**Sans Flutter** : Tu devrais coder 2 fois :
- Une fois pour Android (en Java/Kotlin)
- Une fois pour iOS (en Swift)
= Double travail !

**Avec Flutter** : Un seul code pour les deux !
- Écris en Dart (langage de Flutter)
- Flutter transforme automatiquement pour Android ET iOS
- Interface jolie et fluide

**Ce que Flutter fait dans SmartAgenda** :
- 📱 Crée l'interface que tu vois sur le téléphone
- 🎨 Gère les boutons, listes, formulaires
- 🔄 Communique avec le serveur Python
- 🎙️ Gère le microphone (commande vocale)
- 🔔 Affiche les notifications

**Objectif** : Pouvoir créer une application mobile multi-plateforme

#### A. Téléchargement

1. **Aller sur** : https://docs.flutter.dev/get-started/install/windows
2. **Télécharger** le ZIP Flutter SDK
3. **Extraire** dans `C:\src\flutter` (créer le dossier si nécessaire)

#### B. Ajouter Flutter au PATH

1. **Rechercher** "Variables d'environnement" dans Windows
2. **Cliquer** sur "Variables d'environnement"
3. Dans **Variables système**, trouver **Path** et cliquer **Modifier**
4. **Ajouter** : `C:\src\flutter\bin`
5. **OK** pour tout sauvegarder

#### C. Vérification

```bash
flutter --version
# Résultat : Flutter 3.x.x

flutter doctor
# Cette commande vérifie tout l'environnement
```

**Résultat de `flutter doctor` :**
```
✓ Flutter (Channel stable, 3.x.x)
✗ Android toolchain - develop for Android devices
✗ Visual Studio - develop for Windows (optionnel)
✓ VS Code (version x.x.x)
✓ Connected device (0 available)
```

---

### Étape 1.5 : Installer Android Studio (pour émulateur)

#### A. Installation

1. **Télécharger** sur : https://developer.android.com/studio
2. **Installer** Android Studio
3. **Lancer** et suivre le setup wizard
4. **Installer** les composants par défaut (Android SDK, etc.)

#### B. Créer un Émulateur

1. **Ouvrir** Android Studio
2. **Menu** : Tools → Device Manager
3. **Créer** un appareil virtuel :
   - Modèle : Pixel 6
   - System Image : Android 13 (API 33)
   - Nom : SmartAgenda_Emulator

#### C. Configurer Flutter pour Android

```bash
flutter doctor --android-licenses
# Accepter toutes les licences (taper 'y')

flutter doctor
# Vérifier que Android toolchain est maintenant ✓
```

---

### Étape 1.6 : Installer Git

#### 💡 Pourquoi Git ?

**Git = La machine à remonter le temps pour ton code**

**Le problème sans Git** :
```
Projet_v1.zip
Projet_v2.zip
Projet_v2_final.zip
Projet_v2_final_VRAIMENT_final.zip  ← Confusion totale !
```

**Avec Git** :
- ✅ Chaque modification est sauvegardée automatiquement
- ✅ Tu peux revenir en arrière à n'importe quel moment
- ✅ Tu vois QUI a changé QUOI et QUAND
- ✅ Tu peux travailler sur plusieurs versions en parallèle (branches)

**Analogie** : C'est comme l'historique de versions dans Google Docs, mais en 100x plus puissant

**Objectif** : Gérer les versions de ton code de manière professionnelle

#### A. Installation

1. **Télécharger** sur : https://git-scm.com/download/win
2. **Installer** avec les options par défaut
3. **Important** : Sélectionner "Use Visual Studio Code as Git's default editor"

#### B. Configuration Initiale

```bash
git config --global user.name "Ton Nom"
git config --global user.email "ton.email@example.com"

# Vérification
git config --list
```

---

### Étape 1.7 : Installer Docker Desktop (Optionnel)

#### A. Téléchargement

1. **Aller sur** : https://www.docker.com/products/docker-desktop/
2. **Télécharger** Docker Desktop pour Windows
3. **Installer** et redémarrer l'ordinateur si demandé

#### B. Vérification

```bash
docker --version
# Résultat : Docker version 24.x.x

docker-compose --version
# Résultat : docker-compose version 1.x.x
```

---

### Étape 1.8 : Installer PostgreSQL (Optionnel local)

Pour tester localement sans Supabase :

1. **Télécharger** sur : https://www.postgresql.org/download/windows/
2. **Installer** PostgreSQL 15
3. **Définir** un mot de passe pour l'utilisateur `postgres`
4. **Port** : 5432 (par défaut)

---

## 🏗️ PARTIE 2 : Configuration du Projet

### 💡 Comprendre la Structure d'un Projet

**Un projet = Une maison bien organisée**

Imagine une maison :
- 🏠 **Cuisine** : Là où on prépare (le backend qui traite les données)
- 🛋️ **Salon** : Là où on accueille (l'app mobile que les gens voient)
- 📦 **Cave** : Là où on stocke (la base de données)
- 📁 **Bibliothèque** : Là où on range les documents (dossier docs/)

**La structure du projet SmartAgenda** :
```
SmartAgenda/
├── backend/      ← Le serveur (Python)
├── mobile/       ← L'application (Flutter)
├── docs/         ← La documentation
└── .git/         ← L'historique Git
```

**Pourquoi bien organiser ?**
- ✅ On retrouve facilement les fichiers
- ✅ On sait où ajouter du nouveau code
- ✅ C'est professionnel
- ✅ D'autres développeurs peuvent comprendre

### Étape 2.1 : Créer la Structure du Projet

#### A. Créer le Dossier Racine

```bash
# Ouvrir PowerShell dans le dossier de tes projets
cd "D:\10. Programmation\Projets-Sheila"

# Créer le dossier du projet
mkdir SmartAgenda
cd SmartAgenda
```

#### B. Initialiser Git

```bash
git init
```

#### C. Créer le fichier .gitignore

Créer un fichier `.gitignore` à la racine :

```gitignore
# Python
__pycache__/
*.py[cod]
*$py.class
venv/
.env

# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
build/

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db
```

---

### Étape 2.2 : Créer le Backend (Python/FastAPI)

#### 💡 Qu'est-ce que le Backend ?

**Backend = La cuisine d'un restaurant**

Quand tu vas au restaurant :
- 🍽️ **Ce que tu vois** (Frontend) : La salle, le menu, le serveur
- 👨‍🍳 **Ce que tu ne vois pas** (Backend) : La cuisine où on prépare

Pour SmartAgenda :
- 📱 **Frontend (Mobile)** : L'app sur ton téléphone
- 🖥️ **Backend (Serveur)** : Le "cerveau" invisible qui :
  - Stocke les rendez-vous
  - Calcule les priorités
  - Détecte les conflits
  - Envoie les notifications

**FastAPI** : C'est le "framework" (ensemble d'outils) pour créer le backend facilement

**Objectif** : Créer le serveur qui fera tourner toute la logique de SmartAgenda

#### A. Structure des Dossiers

```bash
mkdir backend
cd backend

# Créer la structure
mkdir app
mkdir app\api
mkdir app\api\v1
mkdir app\api\v1\endpoints
mkdir app\core
mkdir app\schemas
mkdir app\services
mkdir app\utils
```

#### B. Créer l'Environnement Virtuel Python

#### 💡 C'est quoi un Environnement Virtuel ?

**Problème** : Imagine que tu installes des bibliothèques Python pour SmartAgenda, puis tu fais un autre projet qui a besoin de versions différentes. **CONFLIT !**

**Solution : L'environnement virtuel**

**Analogie** : C'est comme avoir plusieurs "boîtes à outils" séparées :
- 🧰 Boîte SmartAgenda : avec SES outils spécifiques
- 🧰 Boîte Autre Projet : avec D'AUTRES outils
- Pas de mélange !

**Ce que ça fait** :
- Crée un dossier `venv/` avec une copie de Python
- Toutes les bibliothèques installées vont dans ce dossier
- N'affecte pas le Python principal de ton ordinateur

**Objectif** : Isoler les dépendances du projet

```bash
# Dans le dossier backend
python -m venv venv

# Activer l'environnement virtuel
# Sur Windows PowerShell :
.\venv\Scripts\Activate.ps1

# Si erreur de politique d'exécution :
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Vérification** : Le terminal doit afficher `(venv)` au début de la ligne.

#### C. Installer les Dépendances Python

Créer `backend/requirements.txt` :

```txt
fastapi==0.109.0
uvicorn[standard]==0.27.0
pydantic==2.5.3
pydantic-settings==2.1.0
supabase==2.3.0
python-dotenv==1.0.0
pyjwt==2.8.0
langchain==0.1.0
openai==1.10.0
apscheduler==3.10.4
google-generativeai==0.3.2
httpx==0.26.0
```

**Installer** :

```bash
pip install -r requirements.txt
```

#### D. Créer le Fichier de Configuration

**Fichier** : `backend/app/core/config.py`

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "SmartAgenda AI"
    API_V1_STR: str = "/api/v1"
    
    # Supabase
    SUPABASE_URL: str
    SUPABASE_KEY: str
    
    # OpenAI (optionnel)
    OPENAI_API_KEY: str = ""
    
    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()
```

#### E. Créer le Fichier .env

**Fichier** : `backend/.env`

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key-here
OPENAI_API_KEY=sk-your-key-here
```

> ⚠️ **Important** : Remplace par tes vraies clés Supabase

#### F. Créer le Point d'Entrée de l'API

**Fichier** : `backend/app/main.py`

```python
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
import traceback

print("🚀 SERVER STARTING...")

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

# Configuration CORS
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex="https?://.*",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Handler d'erreurs global
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    error_msg = f"❌ ERROR: {str(exc)}\n{traceback.format_exc()}"
    print(error_msg)
    return JSONResponse(
        status_code=500,
        content={"message": "Internal Server Error", "detail": str(exc)},
    )

# Routes de base
@app.get("/")
async def root():
    return {"message": "Welcome to SmartAgenda AI API", "status": "running"}

@app.get("/health")
async def health_check():
    return {"status": "ok"}

# TODO: Inclure les routers des endpoints
# from app.api.v1.endpoints import events
# app.include_router(events.router, prefix=f"{settings.API_V1_STR}/events", tags=["events"])
```

#### G. Tester le Serveur

```bash
# Dans backend/ avec (venv) activé
uvicorn app.main:app --reload --port 8000

# Le serveur démarre sur http://localhost:8000
```

**Tester dans le navigateur** : http://localhost:8000

**Résultat attendu** :
```json
{
  "message": "Welcome to SmartAgenda AI API",
  "status": "running"
}
```

---

### Étape 2.3 : Créer l'Application Mobile (Flutter)

#### A. Initialiser le Projet Flutter

```bash
# Revenir à la racine
cd ..

# Créer le projet Flutter
flutter create mobile
cd mobile
```

#### B. Configurer pubspec.yaml

**Fichier** : `mobile/pubspec.yaml`

Remplacer le contenu par :

```yaml
name: smart_agenda_ai
description: SmartAgenda AI Mobile App
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.9
  
  # Networking
  dio: ^5.4.0
  supabase_flutter: ^2.3.0
  
  # UI/UX
  google_fonts: ^6.1.0
  intl: ^0.19.0
  flutter_animate: ^4.5.0
  speech_to_text: ^6.6.0
  
  # Utils
  shared_preferences: ^2.2.2
  uuid: ^4.3.3
  flutter_local_notifications: ^16.3.2
  timezone: ^0.9.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
```

#### C. Installer les Dépendances

```bash
flutter pub get
```

#### D. Créer la Structure des Dossiers

```bash
# Dans mobile/lib/
mkdir lib\core
mkdir lib\features
mkdir lib\features\auth
mkdir lib\features\auth\presentation
mkdir lib\features\events
mkdir lib\features\events\presentation
mkdir lib\features\voice
mkdir lib\features\voice\presentation
```

#### E. Créer le Point d'Entrée

**Fichier** : `mobile/lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartAgenda AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartAgenda AI'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Bienvenue sur SmartAgenda!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            const Text('Votre assistant personnel intelligent'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigation vers création d'événement
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

#### F. Tester l'Application

```bash
# Démarrer l'émulateur Android depuis Android Studio
# OU connecter un téléphone physique en mode développeur

# Vérifier les appareils disponibles
flutter devices

# Lancer l'app
flutter run
```

**Résultat** : L'application s'ouvre avec "Bienvenue sur SmartAgenda!"

---

## 💻 PARTIE 3 : Développement des Fonctionnalités

### Étape 3.1 : Créer la Base de Données (Supabase)

#### 💡 Pourquoi Supabase ?

**Base de données = Le classeur géant de ton app**

**Ce qu'on pourrait faire (difficile)** :
- Installer PostgreSQL localement
- Gérer la sécurité
- Configurer l'authentification
- Sauvegarder les données
= Beaucoup de travail !

**Supabase = Tout ça automatiquement !**
- 🗄️ Base de données PostgreSQL hébergée en ligne
- 🔐 Authentification des utilisateurs intégrée
- 🔒 Sécurité automatique (Row Level Security)
- ☁️ Accessible depuis n'importe où
- 🆓 Version gratuite largement suffisante

**Analogie** : Au lieu de construire et gérer ta propre bibliothèque, tu utilises une bibliothèque municipale déjà prête !

**Objectif** : Avoir une base de données en ligne, sécurisée et gratuite

#### A. Créer un Compte Supabase

1. **Aller sur** : https://supabase.com
2. **S'inscrire** avec GitHub ou email
3. **Créer** un nouveau projet :
   - Nom : SmartAgenda
   - Password : (choisir un mot de passe fort)
   - Région : Europe West (Francfort)

#### B. Exécuter le Script SQL

Dans **Supabase Dashboard** → **SQL Editor** → **New Query**, coller :

```sql
-- Table Users
CREATE TABLE public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    preferences JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table Categories
CREATE TABLE public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    color_hex TEXT NOT NULL,
    priority_level INTEGER DEFAULT 5,
    is_default BOOLEAN DEFAULT FALSE
);

-- Données initiales
INSERT INTO public.categories (name, color_hex, priority_level, is_default) VALUES
('Travail', '#4285F4', 8, TRUE),
('Personnel', '#34A853', 5, FALSE),
('Santé', '#EA4335', 10, FALSE),
('Loisir', '#FBBC05', 3, FALSE);

-- Table Events
CREATE TABLE public.events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID,
    title TEXT NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    location TEXT,
    status TEXT DEFAULT 'confirmed',
    category_id UUID REFERENCES public.categories(id),
    ai_generated BOOLEAN DEFAULT FALSE,
    metadata JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index
CREATE INDEX idx_events_user_id ON public.events(user_id);
CREATE INDEX idx_events_start_time ON public.events(start_time);

-- Sécurité RLS
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable all access for anon" ON public.events FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable read access for categories" ON public.categories FOR SELECT USING (true);
```

**Cliquer** sur **Run** pour exécuter.

#### C. Récupérer les Clés

Dans **Supabase Dashboard** → **Settings** → **API** :

- Copier **Project URL** → Mettre dans `backend/.env` comme `SUPABASE_URL`
- Copier **anon public** key → Mettre dans `backend/.env` comme `SUPABASE_KEY`

---

### Étape 3.2 : Développer l'API Backend (Étape par Étape)

#### A. Créer le Schéma Pydantic pour Events

**Fichier** : `backend/app/schemas/event.py`

```python
from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from uuid import UUID

class EventBase(BaseModel):
    title: str
    start_time: datetime
    end_time: datetime
    location: Optional[str] = None
    category_id: UUID

class EventCreate(EventBase):
    pass

class EventUpdate(BaseModel):
    title: Optional[str] = None
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    location: Optional[str] = None
    category_id: Optional[UUID] = None
    status: Optional[str] = None

class Event(EventBase):
    id: UUID
    user_id: Optional[UUID] = None
    status: str
    ai_generated: bool
    created_at: datetime
    
    class Config:
        from_attributes = True
```

#### B. Créer le Service de Connexion Supabase

**Fichier** : `backend/app/core/database.py`

```python
from supabase import create_client, Client
from app.core.config import settings

supabase: Client = create_client(settings.SUPABASE_URL, settings.SUPABASE_KEY)

def get_supabase() -> Client:
    return supabase
```

#### C. Créer les Endpoints CRUD Events

**Fichier** : `backend/app/api/v1/endpoints/events.py`

```python
from fastapi import APIRouter, HTTPException
from typing import List
from uuid import UUID
from app.schemas.event import Event, EventCreate, EventUpdate
from app.core.database import get_supabase

router = APIRouter()

@router.get("/", response_model=List[Event])
async def get_events():
    """Récupérer tous les événements"""
    try:
        supabase = get_supabase()
        response = supabase.table("events").select("*").execute()
        return response.data
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{event_id}", response_model=Event)
async def get_event(event_id: UUID):
    """Récupérer un événement par ID"""
    try:
        supabase = get_supabase()
        response = supabase.table("events").select("*").eq("id", str(event_id)).execute()
        
        if not response.data:
            raise HTTPException(status_code=404, detail="Event not found")
        
        return response.data[0]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/", response_model=Event)
async def create_event(event: EventCreate):
    """Créer un nouvel événement"""
    try:
        supabase = get_supabase()
        
        event_data = event.model_dump()
        # Convertir datetime en string ISO
        event_data["start_time"] = event.start_time.isoformat()
        event_data["end_time"] = event.end_time.isoformat()
        event_data["category_id"] = str(event.category_id)
        
        response = supabase.table("events").insert(event_data).execute()
        return response.data[0]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/{event_id}", response_model=Event)
async def update_event(event_id: UUID, event: EventUpdate):
    """Mettre à jour un événement"""
    try:
        supabase = get_supabase()
        
        update_data = event.model_dump(exclude_unset=True)
        
        # Convertir les datetime en string si présents
        if "start_time" in update_data:
            update_data["start_time"] = update_data["start_time"].isoformat()
        if "end_time" in update_data:
            update_data["end_time"] = update_data["end_time"].isoformat()
        if "category_id" in update_data:
            update_data["category_id"] = str(update_data["category_id"])
        
        response = supabase.table("events").update(update_data).eq("id", str(event_id)).execute()
        
        if not response.data:
            raise HTTPException(status_code=404, detail="Event not found")
        
        return response.data[0]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{event_id}")
async def delete_event(event_id: UUID):
    """Supprimer un événement"""
    try:
        supabase = get_supabase()
        supabase.table("events").delete().eq("id", str(event_id)).execute()
        return {"message": "Event deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

#### D. Enregistrer les Routes dans main.py

**Mettre à jour** `backend/app/main.py` :

```python
# ... (code existant)

# Importer les routes
from app.api.v1.endpoints import events

# Enregistrer les routers
app.include_router(events.router, prefix=f"{settings.API_V1_STR}/events", tags=["events"])

# ... (reste du code)
```

#### E. Tester l'API

**Démarrer le serveur** :
```bash
cd backend
uvicorn app.main:app --reload --port 8000
```

**Tester avec REST Client VS Code** :

Créer `backend/test_api.http` :

```http
### Get all events
GET http://localhost:8000/api/v1/events

### Create event
POST http://localhost:8000/api/v1/events
Content-Type: application/json

{
  "title": "Test Event",
  "start_time": "2024-01-25T14:00:00Z",
  "end_time": "2024-01-25T15:00:00Z",
  "location": "Office",
  "category_id": "UUID-DE-LA-CATEGORIE-TRAVAIL"
}

### Get event by ID
GET http://localhost:8000/api/v1/events/EVENT-UUID-ICI

### Delete event
DELETE http://localhost:8000/api/v1/events/EVENT-UUID-ICI
```

**Cliquer** sur "Send Request" au-dessus de chaque requête.

---

### Étape 3.3 : Développer l'Interface Mobile Flutter

#### 💡 Comment l'App Parle au Serveur ?

**Le problème de communication :**

L'app mobile (sur ton téléphone) et le serveur backend (sur Internet) sont **deux programmes séparés**. Comment ils se parlent ?

**Solution : L'API (Application Programming Interface)**

**Analogie : Le serveur au restaurant**
- 👤 **Toi (l'app mobile)** : Tu veux manger
- 🍽️ **Le serveur (l'API)** : Prend ta commande
- 👨‍🍳 **La cuisine (le backend)** : Prépare
- 🍽️ **Le serveur** : Te ramène le plat
- 👤 **Toi** : Tu manges !

Pour SmartAgenda :
1. App mobile : "Donne-moi tous les rendez-vous"
2. API : Transmet la demande au backend
3. Backend : Cherche dans la base de données
4. API : Renvoie les rendez-vous à l'app
5. App : Affiche les rendez-vous à l'écran

**Objectif** : Permettre à l'app de communiquer avec le serveur

#### A. Créer le Service API

**Fichier** : `mobile/lib/core/api_service.dart`

```dart
import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';  // Pour émulateur Android
  // Pour iOS: 'http://localhost:8000'
  // Pour device physique: 'http://YOUR-IP:8000'
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));
  
  Dio get dio => _dio;
}
```

#### B. Créer le Modèle Event

**Fichier** : `mobile/lib/features/events/data/models/event_model.dart`

```dart
class EventModel {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final String categoryId;
  final String status;
  
  EventModel({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.location,
    required this.categoryId,
    required this.status,
  });
  
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      location: json['location'],
      categoryId: json['category_id'],
      status: json['status'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'location': location,
      'category_id': categoryId,
    };
  }
}
```

#### C. Créer le Repository

**Fichier** : `mobile/lib/features/events/data/repositories/event_repository.dart`

```dart
import 'package:dio/dio.dart';
import 'package:smart_agenda_ai/core/api_service.dart';
import 'package:smart_agenda_ai/features/events/data/models/event_model.dart';

class EventRepository {
  final ApiService _apiService = ApiService();
  
  Future<List<EventModel>> getEvents() async {
    try {
      final response = await _apiService.dio.get('/api/v1/events');
      final List<dynamic> data = response.data;
      return data.map((json) => EventModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load events: $e');
    }
  }
  
  Future<EventModel> createEvent(EventModel event) async {
    try {
      final response = await _apiService.dio.post(
        '/api/v1/events',
        data: event.toJson(),
      );
      return EventModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }
  
  Future<void> deleteEvent(String id) async {
    try {
      await _apiService.dio.delete('/api/v1/events/$id');
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }
}
```

#### D. Créer le Provider Riverpod

**Fichier** : `mobile/lib/features/events/presentation/providers/events_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_agenda_ai/features/events/data/models/event_model.dart';
import 'package:smart_agenda_ai/features/events/data/repositories/event_repository.dart';

final eventRepositoryProvider = Provider((ref) => EventRepository());

final eventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  return await repository.getEvents();
});
```

#### E. Créer la Page Liste d'Événements

**Fichier** : `mobile/lib/features/events/presentation/pages/events_list_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smart_agenda_ai/features/events/presentation/providers/events_provider.dart';

class EventsListPage extends ConsumerWidget {
  const EventsListPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Rendez-vous'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: eventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return const Center(
              child: Text('Aucun rendez-vous pour le moment'),
            );
          }
          
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.event, color: Colors.white),
                  ),
                  title: Text(event.title),
                  subtitle: Text(
                    '${DateFormat('dd/MM/yyyy HH:mm').format(event.startTime)}\n'
                    '${event.location ?? "Pas de lieu"}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final repo = ref.read(eventRepositoryProvider);
                      await repo.deleteEvent(event.id);
                      ref.invalidate(eventsProvider);  // Rafraîchir la liste
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erreur: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigation vers page création
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

#### F. Mettre à Jour main.dart

```dart
// Dans home: remplacer HomePage() par :
home: const EventsListPage(),
```

#### G. Tester l'Application Complète

1. **S'assurer** que le backend tourne (`uvicorn app.main:app --reload --port 8000`)
2. **Lancer** l'app mobile : `flutter run`
3. **Vérifier** que la liste d'événements s'affiche
4. **Tester** la suppression d'un événement

---

## 📊 PARTIE 4 : Tests et Déploiement

### Étape 4.1 : Tests Backend

#### A. Créer des Tests Unitaires

**Fichier** : `backend/tests/test_events.py`

```python
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["status"] == "running"

def test_get_events():
    response = client.get("/api/v1/events")
    assert response.status_code == 200
    assert isinstance(response.json(), list)
```

#### B. Exécuter les Tests

```bash
# Installer pytest
pip install pytest

# Lancer les tests
pytest tests/
```

---

### Étape 4.2 : Déploiement Backend

#### A. Créer Dockerfile

**Fichier** : `backend/Dockerfile`

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

#### B. Build et Test Docker

```bash
# Build l'image
docker build -t smartagenda-backend .

# Lancer le container
docker run -p 8001:8000 smartagenda-backend
```

---

### Étape 4.3 : Build APK Android

```bash
cd mobile

# Build en mode release
flutter build apk --release

# L'APK est dans : build/app/outputs/flutter-apk/app-release.apk
```

---

## ✅ Checklist Complète

- [ ] VS Code installé avec toutes les extensions
- [ ] Python 3.11 installé et dans PATH
- [ ] Flutter SDK installé et configuré
- [ ] Android Studio et émulateur configurés
- [ ] Git installé et configuré
- [ ] Docker installé (optionnel)
- [ ] Projet backend créé avec structure correcte
- [ ] Environnement virtuel Python activé
- [ ] Dépendances Python installées
- [ ] Base de données Supabase créée
- [ ] API Backend fonctionnelle (CRUD events)
- [ ] Projet Flutter créé
- [ ] App mobile connectée au backend
- [ ] Tests backend passent
- [ ] APK Android buildé

---

## 🎓 Conclusion

Tu as maintenant un environnement complet et fonctionnel ! Ce guide t'a montré **comment tout installer et coder manuellement** chaque partie du projet.

**Points clés** :
- Installation méthodique de tous les outils
- Configuration précise de l'environnement
- Développement pas à pas du backend et mobile
- Tests et déploiement

**Prochaines étapes** :
- Ajouter plus de fonctionnalités (notifications, voix, IA)
- Améliorer l'UI
- Tests plus complets
- Déploiement en production

Ce processus manuel te donne une compréhension profonde de chaque composant du projet ! 🚀
