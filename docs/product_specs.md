# Spécifications Produit - SmartAgenda AI

## 1. Description Générale
SmartAgenda AI est un assistant personnel intelligent conçu pour optimiser la gestion du temps grâce à l'automatisation, la priorisation contextuelle et une interaction naturelle (vocale et visuelle). L'objectif est de réduire la charge mentale liée à la planification en déléguant la gestion des rappels, des conflits et des reprogrammations à une IA.

## 2. Fonctionnalités Obligatoires

### 2.1 Gestion des Rendez-vous (CRUD)
- **Création Manuelle** : Formulaire intuitif (Titre, Date/Heure, Lieu, Type, Couleur, Notes).
- **Création Vocale** : Saisie par commandes naturelles ("Rendez-vous dentiste demain 14h").
- **Catégorisation** : Types prédéfinis (Travail, Perso, Santé, Loisir) avec codes couleurs.
- **Enrichissement** : Ajout automatique ou manuel de la géolocalisation et d'images/icônes.

### 2.2 Système de Notifications Intelligent
- **Alertes Anticipées** : Notification la veille (récapitulatif).
- **Alerte Jour J** : Rappel avant l'événement (temps de trajet inclus).
- **Audio/Musical** : Option pour des rappels sous forme de "jingles" ou messages vocaux personnalisés.
- **Anti-Surcharge** : Alerte proactive si le planning dépasse un seuil de densité défini.
- **Gestion Automatique** : Suppression des rappels pour les événements annulés/supprimés.
- **Mode Freeze** : Bouton d'urgence pour suspendre toutes les notifications non critiques pendant une durée donnée (ex: 2h pour concentration).

### 2.3 Intelligence Artificielle (Cœur du Système)
- **Planification Automatique des Rappels** : L'IA définit le meilleur moment pour notifier selon l'importance.
- **Détection de Conflits** : Identification immédiate des chevauchements.
- **Reprogrammation Intelligente** : Suggestion de nouveaux créneaux en cas d'annulation ou conflit, basée sur les habitudes.
- **Priorisation Dynamique** : Classement des événements (Critique, Important, Normal, Faible) selon :
    - Catégorie (ex: Santé > Loisir)
    - Fréquence (Répétitif vs Ponctuel)
    - Historique (Taux de présence/annulation)
- **Gestion Contextuelle** : Intégration automatique des jours fériés et fêtes selon la locale.
- **Rapports Analytiques** : Résumés quotidiens et hebdomadaires de l'activité.

### 2.4 Visualisation & UI
- **Vue Journalière (Timeline)** : Focus sur le flux immédiat.
- **Vue Hebdomadaire** : Vue d'ensemble de la charge.
- **Onglet "Meetings"** : Liste filtrée dédiée aux rendez-vous professionnels.
- **Résumé Intelligent** : "Ce qu'il faut savoir aujourd'hui" (Top 3 priorités).

### 2.5 Fonctionnalités Avancées (Intégrées V1)
- **Gestion de l'Énergie** : Planification basée sur les rythmes biologiques (Chronobiologie) et l'état de fatigue.
- **Bouclier Anti-Burnout** : Détection proactive de la surcharge (>10h/jour) et blocage de plages de repos.
- **Smart Travel & Météo** : Alertes contextuelles (Pluie = changement de lieu, Bouchons = départ anticipé).
- **Smart Booking** : Liens de partage de disponibilités respectant les règles de vie privée.
- **Preparation Mode** : Envoi automatique d'un digest (Contexte, LinkedIn, Notes) 15 min avant les réunions.

## 3. Flux Utilisateurs Clés

### 3.1 Création d'un Rendez-vous (Vocal)
1.  Utilisateur active le micro : "Déjeuner avec Sophie jeudi midi au centre-ville."
2.  IA analyse (NLU) et extrait : Titre="Déjeuner Sophie", Date="Jeudi prochain", Heure="12:00", Lieu="Centre-ville" (propose adresse précise).
3.  Confirmation visuelle rapide (Toaster/Modal).
4.  L'utilisateur valide ou corrige vocalement/manuellement.
5.  Rendez-vous ajouté + Rappels auto-configurés.

### 3.2 Gestion de Conflit
1.  Utilisateur tente d'ajouter un événement sur un créneau occupé.
2.  Système détecte le conflit.
3.  Affichage d'une alerte : "Conflit avec 'Réunion Marketing'".
4.  IA propose :
    - "Maintenir et superposer"
    - "Reprogrammer 'Réunion Marketing' à 16h (créneau libre)"
    - "Trouver un autre créneau pour le nouvel événement"

### 3.3 Mode "Freeze"
1.  Utilisateur se sent débordé ou veut se concentrer.
2.  Clic sur bouton "Freeze".
3.  Sélection durée (30m, 1h, 2h, Indéfini).
4.  App confirmation : "Notifications suspendues jusqu'à 15h00. Seules les urgences absolues passeront."
5.  État visuel de l'app change (thème "calme/sombre").

### 3.4 Gestion de la Surcharge
1.  IA analyse la densité du planning (ex: >6h de réunions/jour).
2.  Notification proactive : "Votre journée de mardi est très chargée (8h de meetings)."
3.  Proposition : "Voulez-vous bloquer le reste de la journée ou déplacer des événements non prioritaires ?"

### 3.5 Rapport Hebdomadaire
1.  Dimanche soir ou Lundi matin (configurable).
2.  Notification "Votre bilan de la semaine est prêt".
3.  Écran résumé :
    - Nombre de RDV honorés vs annulés.
    - Temps total en réunion.
    - Catégorie dominante (ex: 60% Travail).
    - Suggestions pour la semaine à venir ("Prévoir plus de pauses").
