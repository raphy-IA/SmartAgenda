# ⚡ Commandes Rapides (Cheat Sheet)

## 🖥 Développement Local (PC)
- **Backend IA** :
  ```powershell
  cd backend ; ..\venv\Scripts\Activate.ps1 ; uvicorn app.main:app --reload --port 8001
  ```
- **Lancer l'App** :
  ```powershell
  cd mobile
  flutter run -d chrome  # Web
  flutter run -d android # Mobile (F5 dans VS Code est plus simple)
  ```

## 📦 Construire & Installer l'APK (Sans Drive)
1. **Générer l'APK** : 
   ```powershell
   cd mobile ; flutter build apk --release
   ```
2. **Installer sur téléphone branché** :
   ```powershell
   cd mobile ; flutter install
   ```

## 🚀 Mise à jour Production (VPS)
1. **Pousser le code** : `git add . ; git commit -m "maj" ; git push`
2. **Déployer sur VPS** : 
   ```bash
   cd /home/raphyai82/apps/SmartAgenda/SmartAgenda
   git pull origin main
   docker compose up -d --build backend
   ```
3. **Générer l'APK** : Allez sur GitHub -> Actions -> Build Android APK -> **Run workflow**.

---
💡 *Plus de détails techniques dans le [**MASTER_DEVELOPER_GUIDE.md**](../../MASTER_DEVELOPER_GUIDE.md)*
