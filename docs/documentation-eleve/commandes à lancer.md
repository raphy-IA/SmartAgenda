Lancer le Backend :
PS D:\10. Programmation\Projets-Sheila\Agenda\backend> ..\venv\Scripts\Activate.ps1
(venv) PS D:\10. Programmation\Projets-Sheila\Agenda\backend> uvicorn app.main:app --reload --port 8001

Doc interactive : http://localhost:8001/docs

Lancer le Frontend (Mobile) :
cd D:\10. Programmation\Projets-Sheila\Agenda\mobile

- Chrome (Mode Démo) : flutter run -d chrome --web-port 5000
- Android (Simulateur) : flutter run -d android
- Windows (Bureau)     : flutter run -d windows

💡 ASTUCE : Sur Chrome, utilise le bouton "Mode Démo" pour accéder à l'app sans erreurs Google.
