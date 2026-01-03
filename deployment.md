# Guide de Déploiement Production 🚀

Ce guide vous explique comment passer de "ça marche sur mon PC" à "ça marche partout".

## Partie 1 : Le Backend (Sur votre VPS Linux)

La méthode la plus simple et robuste est d'utiliser **Docker**.

### 1. Préparer le VPS
Connectez-vous à votre VPS et installez Docker :
```bash
sudo apt update
sudo apt install docker.io
```

### 2. Récupérer le Code
```bash
git clone https://github.com/raphy-IA/SmartAgenda.git
cd SmartAgenda/backend
```

### 3. Configurer l'Environnement
Créez un fichier `.env` de production :
```bash
nano .env
```
Collez-y vos clés (GROQ_API_KEY, SUPABASE_URL, etc.).

### 4. Lancer le Serveur
Construisez et lancez le conteneur :
```bash
sudo docker build -t smartagenda-backend .
sudo docker run -d -p 80:8000 --name api --env-file .env --restart always smartagenda-backend
```
*Note : Cela expose l'API sur le port 80 (HTTP standard). Pour HTTPS, l'idéal est d'utiliser Nginx en reverse-proxy avec Certbot.*

---

## Partie 2 : L'Application Android (APK)

Pour installer l'appli sur un vrai téléphone, il faut générer un fichier `.apk`.

### 1. Changer l'URL de l'API
C'est l'étape CRITIQUE. L'appli ne peut plus taper sur `127.0.0.1` (localhost). Elle doit taper sur l'IP ou le Domaine de votre VPS.

**Fichier 1 :** `mobile/lib/features/voice/data/repositories/voice_repository.dart`
**Fichier 2 :** `mobile/lib/features/events/data/repositories/category_repository.dart`
**Fichier 3 :** `mobile/lib/features/events/data/repositories/event_repository.dart` (si applicable)

Remplacez :
```dart
final String baseUrl = "http://127.0.0.1:8000/api/v1";
```
Par :
```dart
final String baseUrl = "http://VOTRE_IP_VPS_OU_DOMAINE/api/v1";
```

### 2. Signer l'Application (Keystore)
Android exige une signature numérique.
Si c'est juste pour vous (debug/test), vous pouvez sauter la signature complexe et faire un APK de debug.
Pour une vraie "Release", suivez la doc Flutter.

### 3. Construire l'APK
Dans le dossier `mobile` :
```powershell
flutter build apk --release
```
*(Cela peut prendre quelques minutes).*

### 4. Installer
Le fichier généré sera dans :
`mobile/build/app/outputs/flutter-apk/app-release.apk`

Envoyez ce fichier sur votre téléphone (par USB, Drive, mail...) et ouvrez-le. Android demandera d'autoriser l'installation depuis des sources inconnues. Acceptez.

---

## Résumé
1.  **VPS** : Backend tourne tout seul avec Docker.
2.  **App** : Pointe vers le VPS, compilée en APK, installée sur le mobile.

Vous avez maintenant un système pro ! 🎉
