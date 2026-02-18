# ⚡ Commandes Rapides (Cheat Sheet)

## 🖥 Développement Local (PC)
- **Backend IA** :
  ```powershell
  cd backend
  ..\venv\Scripts\Activate.ps1
  uvicorn app.main:app --reload --port 8001
  ```
- **Frontend App** :
  ```powershell
  cd mobile
  flutter run -d chrome  # Web (Mode Démo)
  flutter run -d android # Mobile physique ou émulateur
  ```

## 🚀 Mise à jour Production (VPS)
1. **Pousser le code local** :
   ```powershell
   git add .
   git commit -m "Mise à jour"
   git push
   ```
2. **Déployer sur VPS** (via Docker) :
   ```bash
   # Connectez-vous en SSH à votre VPS, puis :
   cd /home/raphyai82/apps/SmartAgenda/SmartAgenda
   git pull origin main
   docker compose up -d --build backend
   ```
3. **Récupérer l'APK** : Allez sur votre dépôt GitHub -> Onglet **Actions** -> Dernier run réussi -> Section **Artifacts** (en bas).

---
💡 *Plus de détails techniques dans le [**MASTER_DEVELOPER_GUIDE.md**](../../MASTER_DEVELOPER_GUIDE.md)*
