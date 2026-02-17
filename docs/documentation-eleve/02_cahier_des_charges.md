# 📋 Cahier des Charges - SmartAgenda AI

## 📌 Introduction

Le **cahier des charges** est un document très important dans tout projet. C'est comme une "recette de cuisine" détaillée qui explique :
- Ce que doit faire le projet
- Comment il doit le faire
- Les règles à respecter

Ce document sert de **contrat** entre les développeurs et les utilisateurs finaux.

---

## 🎯 1. Objectifs du Projet

### 1.1 Objectif Principal

Créer une **application mobile intelligente** qui aide les utilisateurs à mieux gérer leur temps et leurs rendez-vous en utilisant l'intelligence artificielle.

### 1.2 Objectifs Spécifiques

| # | Objectif | Description |
|---|----------|-------------|
| 1 | **Simplifier la planification** | Permettre de créer des rendez-vous en quelques secondes |
| 2 | **Éviter les oublis** | Envoyer des rappels intelligents au bon moment |
| 3 | **Détecter les erreurs** | Alerter quand deux rendez-vous sont en conflit |
| 4 | **Utiliser la voix** | Permettre de créer des rendez-vous en parlant |
| 5 | **Protéger la santé mentale** | Détecter la surcharge et suggérer des pauses |

---

## 👥 2. Public Cible (À Qui S'adresse l'Application ?)

### Utilisateurs Principaux

1. **Étudiants (15-25 ans)**
   - Besoin : Gérer cours, devoirs, activités extrascolaires
   - Fréquence : Utilisation quotidienne

2. **Professionnels (25-60 ans)**
   - Besoin : Gérer réunions, rendez-vous clients, deadlines
   - Fréquence : Utilisation intensive (plusieurs fois par jour)

3. **Familles**
   - Besoin : Organiser rendez-vous médicaux, activités des enfants
   - Fréquence : Utilisation régulière

### Niveau Technique Requis
- ✅ Aucune compétence technique nécessaire
- ✅ Savoir utiliser un smartphone basique
- ✅ Comprendre le français

---

## ⚙️ 3. Fonctionnalités Obligatoires

### 3.1 Gestion des Rendez-vous (CRUD)

> **CRUD** signifie : **C**reate (Créer), **R**ead (Lire), **U**pdate (Modifier), **D**elete (Supprimer)

#### A. Créer un Rendez-vous

**Méthodes disponibles :**

1. **Manuelle** (Formulaire)
   - Champs à remplir :
     - Titre (ex: "Rendez-vous dentiste")
     - Date et heure
     - Lieu (optionnel)
     - Catégorie (Travail, Santé, Loisir, etc.)
     - Couleur
     - Notes personnelles

2. **Vocale** (Parler)
   - Exemples de commandes :
     - *"Rendez-vous dentiste demain à 14h"*
     - *"Déjeuner avec Sophie vendredi midi"*
     - *"Réunion équipe lundi 9h"*

#### B. Consulter les Rendez-vous

**Vues disponibles :**
- Vue **Jour** : Voir tous les rendez-vous d'une journée
- Vue **Semaine** : Voir la semaine complète
- Liste des **Réunions** seulement (filtre)

#### C. Modifier un Rendez-vous

L'utilisateur peut :
- Changer la date/heure
- Modifier le titre ou la description
- Annuler le rendez-vous

#### D. Supprimer un Rendez-vous

- Suppression simple avec confirmation
- Les rappels associés sont automatiquement supprimés

### 3.2 Système de Notifications Intelligentes

#### Types de Rappels

1. **Rappel la veille** (J-1)
   - Envoyé à 20h
   - Contenu : "Demain : [Liste des RDV importants]"

2. **Rappel le jour J**
   - Calculé intelligemment selon :
     - Temps de trajet estimé
     - Temps de préparation nécessaire
     - Marge de sécurité (10 minutes)

**Exemple de calcul :**
```
Rendez-vous à 14h00
- Temps de trajet : 30 minutes
- Temps de préparation : 15 minutes
- Marge de sécurité : 10 minutes
→ Rappel à 13h05
```

3. **Rappels spéciaux**
   - Messages vocaux personnalisés (optionnel)
   - Notification urgente pour événements critiques

#### Mode "Freeze" (Gel des Notifications)

**Fonctionnement :**
- Bouton d'urgence accessible facilement
- Options de durée : 30min, 1h, 2h, Indéfini
- Seules les notifications CRITIQUES passent
- Interface visuelle change (mode calme)

### 3.3 Intelligence Artificielle

#### A. Détection Automatique des Conflits

**Scénarios gérés :**

1. **Conflit simple** : Deux rendez-vous en même temps
   - Action : Alerte immédiate
   - Proposition : Suggestions de nouveaux créneaux

2. **Conflit de priorité**
   - L'IA compare l'importance des deux rendez-vous
   - Propose de déplacer le moins important

**Exemple :**
```
Nouveau RDV : Dentiste (Priorité : 90/100)
RDV existant : Sport hebdo (Priorité : 40/100)
→ Proposition : "Déplacer le sport à 16h ?"
```

#### B. Priorisation Automatique

L'IA attribue automatiquement un **score de priorité** à chaque rendez-vous :

| Catégorie | Score de Base | Facteurs Bonus |
|-----------|---------------|----------------|
| Santé | 90 | +10 si unique |
| Travail (Client) | 80 | +10 si historique présence élevé |
| Travail (Interne) | 60 | -15 si souvent annulé |
| Social | 50 | - |
| Personnel | 40 | - |

#### C. Suggestions Intelligentes

- **Reprogrammation** : Propose automatiquement des créneaux libres
- **Pause automatique** : Détecte si la journée est trop chargée
- **Adaptation** : Apprend de tes habitudes

### 3.4 Protection Anti-Burnout

#### Règles de Détection

L'application alerte si :
- ✋ Plus de **8 heures** de rendez-vous dans une journée
- ✋ Moins de **30 minutes** de pause entre rendez-vous longs
- ✋ Plus de **5 jours consécutifs** très chargés

#### Actions Automatiques

Quand une surcharge est détectée :
1. Notification proactive : "Attention, journée très chargée !"
2. Proposition : "Voulez-vous bloquer le reste de la journée ?"
3. Suggestion : Déplacer rendez-vous non-urgents

### 3.5 Rapports et Statistiques

#### Rapport Hebdomadaire

Envoyé chaque **dimanche soir** ou **lundi matin** (au choix) :

**Contenu :**
- 📊 Nombre de rendez-vous respectés vs annulés
- ⏱️ Temps total en réunions
- 📈 Catégorie dominante (ex: 60% Travail, 30% Santé, 10% Loisir)
- 💡 Suggestions pour la semaine prochaine

**Exemple de suggestion :**
> "Cette semaine, tu as eu beaucoup de réunions (12h total). La semaine prochaine, pense à bloquer des plages de concentration !"

---

## 🛠️ 4. Exigences Techniques

### 4.1 Plateformes Supportées

- ✅ **Android** : Version 8.0 (Oreo) et supérieure
- ✅ **iOS** : Version 12.0 et supérieure

### 4.2 Connexion Internet

- **Obligatoire** : Pour la synchronisation et l'IA
- **Mode Hors-ligne** : Vue en lecture seule des rendez-vous

### 4.3 Permissions Nécessaires

L'application demande l'autorisation pour :
- 🎤 **Microphone** : Pour la commande vocale
- 🔔 **Notifications** : Pour les rappels
- 📍 **Localisation** (optionnel) : Pour calculer le temps de trajet
- 📅 **Calendrier** (optionnel) : Pour importer des rendez-vous existants

### 4.4 Performances

| Critère | Exigence |
|---------|----------|
| Temps de chargement | < 2 secondes |
| Temps de réponse (création RDV) | < 1 seconde |
| Reconnaissance vocale | > 90% de précision |
| Consommation batterie | < 5% par jour |

### 4.5 Sécurité

#### Données Protégées

- ✅ Toutes les informations personnelles sont chiffrées
- ✅ Les mots de passe ne sont jamais stockés en clair
- ✅ Connexion sécurisée (HTTPS)

#### Respect de la Vie Privée

- ❌ Aucune vente de données à des tiers
- ❌ Pas de publicité ciblée
- ✅ L'utilisateur peut supprimer son compte à tout moment

---

## 🎨 5. Exigences Design (Interface Utilisateur)

### 5.1 Principes de Design

1. **Simplicité** : Interface claire et intuitive
2. **Rapidité** : Créer un RDV en moins de 3 clics
3. **Beauté** : Design moderne et agréable à l'œil
4. **Accessibilité** : Lisible pour tous (grandes polices disponibles)

### 5.2 Couleurs et Thèmes

- 🌞 **Mode Clair** : Disponible par défaut
- 🌙 **Mode Sombre** : Pour utilisation nocturne
- 🎨 **Codes couleurs par catégorie** :
  - Travail : Bleu (#4285F4)
  - Santé : Rouge (#EA4335)
  - Personnel : Vert (#34A853)
  - Loisir : Jaune (#FBBC05)

### 5.3 Navigation

**Écrans principaux :**
1. **Accueil** : Vue d'ensemble de la journée
2. **Calendrier** : Vue semaine/mois
3. **Créer** : Nouveau rendez-vous (vocal ou manuel)
4. **Paramètres** : Préférences utilisateur
5. **Statistiques** : Rapports et analyses

---

## 📅 6. Planning de Réalisation

### Phase 1 : MVP (3 mois)

**Mois 1 - Fondations**
- Setup des outils de développement
- Création de la base de données
- Interface basique (CRUD rendez-vous)

**Mois 2 - Intelligence**
- Système de notifications
- Détection de conflits
- Calcul de priorités

**Mois 3 - Finitions**
- Commande vocale
- Mode anti-burnout
- Design final et tests

### Phase 2 : Améliorations (3 mois suivants)
- Rapports hebdomadaires
- Intégration Google Calendar
- Nouvelles fonctionnalités IA

---

## ✅ 7. Critères de Réussite

### Comment Sait-on que le Projet est Réussi ?

1. **Fonctionnel** ✅
   - Toutes les fonctionnalités principales fonctionnent
   - Pas de bugs critiques

2. **Utilisable** ✅
   - Interface facile à comprendre
   - Moins de 3 clics pour créer un RDV

3. **Performant** ✅
   - Application rapide (< 2s de chargement)
   - Reconnaissance vocale précise (> 90%)

4. **Apprécié** ✅
   - Note utilisateurs > 4/5 étoiles
   - Retours positifs sur l'utilité

5. **Fiable** ✅
   - Pas de perte de données
   - Notifications envoyées à l'heure

---

## 🚫 8. Ce qui N'est PAS Inclus (Hors Périmètre)

Pour garder le projet réalisable, certaines fonctionnalités sont **exclues** de la première version :

- ❌ Synchronisation multi-appareils (tablette, ordinateur)
- ❌ Partage de calendrier entre plusieurs personnes
- ❌ Intégration avec d'autres applications (Outlook, etc.)
- ❌ Mode complètement hors-ligne
- ❌ Support d'autres langues (seulement français au début)

> 💡 **Note** : Ces fonctionnalités pourront être ajoutées dans les versions futures !

---

## 📊 9. Budget et Ressources

### Ressources Humaines Nécessaires

- **1 Développeur Mobile** (Flutter) : Interface utilisateur
- **1 Développeur Backend** (Python) : Serveur et IA

### Technologies Utilisées

- **Mobile** : Flutter/Dart
- **Backend** : Python/FastAPI
- **Base de données** : PostgreSQL (via Supabase)
- **IA** : OpenAI / Google Gemini

### Coûts Estimés (Pour Information)

| Poste | Coût Mensuel |
|-------|--------------|
| Serveur Cloud | ~20€/mois |
| Base de données | ~10€/mois |
| API IA (OpenAI) | ~30€/mois |
| **Total** | **~60€/mois** |

---

## 📝 10. Livrables Attendus

À la fin du projet, tu dois avoir :

1. ✅ **Application mobile fonctionnelle** (fichier .apk pour Android / .ipa pour iOS)
2. ✅ **Code source complet** (organisé et commenté)
3. ✅ **Documentation technique** (comment ça fonctionne)
4. ✅ **Guide utilisateur** (comment utiliser l'app)
5. ✅ **Présentation du projet** (pour exposé scolaire)

---

## 🎓 Conclusion

Ce cahier des charges définit **clairement** ce que doit faire SmartAgenda AI. C'est un document de référence qui guide tout le développement du projet.

**Points Clés à Retenir :**
- L'application doit être **simple** et **intelligente**
- L'IA aide à **mieux organiser** le temps
- La **sécurité** et la **vie privée** sont prioritaires
- Le projet est **réalisable** en 3 mois pour le MVP

---

## 💬 Glossaire du Cahier des Charges

| Terme | Définition |
|-------|------------|
| **MVP** | Version minimale mais fonctionnelle du projet |
| **CRUD** | Créer, Lire, Modifier, Supprimer des données |
| **Backend** | Partie serveur invisible pour l'utilisateur |
| **Frontend** | Partie visible (interface utilisateur) |
| **IA** | Intelligence Artificielle |
| **API** | Interface de communication entre programmes |
| **Hors périmètre** | Ce qui n'est pas inclus dans le projet |
| **Livrable** | Document ou produit à fournir à la fin |
