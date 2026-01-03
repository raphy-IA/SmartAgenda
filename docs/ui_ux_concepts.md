# Concept UI/UX & Écrans Principaux - SmartAgenda AI

## 1. Philosophie UX
**"Productivité Zen"** : L'interface doit être épurée, sans surcharge cognitive. L'IA travaille en arrière-plan ("Invisible AI"), ne sollicitant l'utilisateur que lorsque nécessaire.
- **Palette** : Mode sombre par défaut (OLED Black, Gris anthracite), accents néon (Bleu électrique pour le pro, Vert menthe pour le perso, Rouge doux pour urgente).
- **Interactions** : Usage intensif des gestes (Swipe pour compléter/annuler, Long press pour déplacer).

## 2. Écrans Principaux

### 2.1 Écran d'Accueil "Dashboard Zen"
C'est le hub central. Il ne montre pas *tout*, mais ce qui compte *maintenant*.
- **Header** : Salutation dynamique ("Bonjour Alex, 3 RDV aujourd'hui"). Bilan météo rapide.
- **Section "Now / Next"** : Carte large affichant l'événement en cours ou le prochain. Compte à rebours ("Dans 35 min"). Bouton d'action rapide (GPS, Appeler).
- **Timeline Verticale** : Liste des événements de la journée. Les créneaux vides sont masqués ou compressés visuellement.
- **Floating Action Button (FAB)** : Bouton "+" central avec micro intégré pour la commande vocale immédiate.

### 2.2 Vue Calendrier (Hebdo/Mensuel)
- **Navigation** : Swipe horizontal pour changer de semaine.
- **Densité** : Visualisation par "blocs de chaleur" (couleurs plus ou moins intenses selon la charge) plutôt que du texte illisible.
- **Zoom** : Pinch-to-zoom pour passer de la vue "Bird's eye" (Mois) à la vue détaillée (Jour).

### 2.3 Écran "Création Rapide" (Modal)
- S'ouvre par dessus le dashboard (Bottom Sheet).
- **Champs** : Titre (auto-complétion intelligente), Heure (roulette tactile), Type (Tags colorés).
- **Zone IA** : Suggestion automatique en temps réel ("Créneau libre : 14h00 ?").
- **Switch "Prioritaire"** : Pour forcer le passage en cas de conflit.

### 2.4 Centre de Notifications Intelligent
- Pas une liste chronologique bête. Groupement par urgence.
- **Section "À traiter"** : Conflits à résoudre, validations demandées par l'IA.
- **Section "Info"** : Rappels simples, suggestions ("Demain est férié").

### 2.5 Onglet "Meetings Focus"
- Vue épurée filtrant tout le "bruit" personnel.
- Liste des réunions pro avec : Photo des participants, Lien Visio (Zoom/Teams) en gros bouton, Ordre du jour (extrait des notes).

## 3. Feedback Visuel & Sonore
- **Succès** : Micro-animation (confettis discrets) lors de la complétion d'une tâche.
- **Alerte** : Vibration haptique distincte pour les conflits vs rappels.
- **Mode Freeze** : L'interface se désature (devient monochrome) pour signifier le mode "Focus".
