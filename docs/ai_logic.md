# Logique & Règles IA - SmartAgenda AI

## 1. Moteur de Priorisation (Scoring)
Chaque événement se voit attribuer un "Score d'Importance" (IS) de 0 à 100.
**Formule :** `IS = (Catégorie_Base * Poids_Cat) + (Facteur_Type) + (Historique_User)`

- **Poids Catégories (Configurable)** :
    - Santé (Médecin) : 90
    - Travail (Réunion client) : 80
    - Travail (Interne) : 60
    - Social (Repas, Fête) : 50
    - Personnel (Sport, Courses) : 40
- **Facteur Type** :
    - Ponctuel (Unique) : +10
    - Récurrent : +0
- **Historique Utilisateur** :
    - Si taux d'annulation > 50% sur ce type : -15 (Moins prioritaire)
    - Si taux de présence > 90% : +10

*Exemple :* "RDV Dentiste" (90) + Ponctuel (+10) = Score 100 (Critique).
"Sport hebdo" (40) + Récurrent (0) + Souvent annulé (-15) = Score 25 (Faible).

## 2. Algorithme de Gestion des Conflits
**Logique de détection :** Trigger `BEFORE INSERT/UPDATE` sur la table `events`.

**Si chevauchement détecté (`start_new < end_existing AND start_existing < end_new`) :**
1.  Calculer `IS_New` et `IS_Existing`.
2.  **Scénario A (IS_New > IS_Existing + 20)** : "Nouveau RDV critique".
    - Action : Proposer automatiquement le remplacement.
    - Message : "Ce RDV est plus important. Voulez-vous déplacer l'ancien ?"
3.  **Scénario B (Scores proches)** : "Conflit Standard".
    - Action : Alerte bloquante.
    - Message : "Conflit détecté. Que faire ?"
4.  **Scénario C (IS_New < IS_Existing - 30)** : "Nouveau RDV faible".
    - Action : Avertissement discret ("Votre planning est déjà chargé par un événement prioritaire").

## 3. Planification Intelligente des Notifications
L'IA calcule le moment optimal `T_Notify` pour l'alerte.

`T_Notify = T_Event - (T_Trajet + T_Prep + T_Buffer)`

- **T_Trajet** : API Google Maps/Waze (si lieu défini) ou valeur par défaut (30m).
- **T_Prep** : Temps de préparation (15m par défaut, 45m si événement "Soirée/Gala").
- **T_Buffer** : Marge de sécurité (10m).

*Règle anti-spam* : Si `T_Notify` tombe entre 23h et 07h, décaler à 07h00 le jour J (sauf urgence).

## 4. Intégration LLM (Langage Naturel)
**Stack** : OpenAI GPT-4o-mini (rapide/économique) ou modèle local (Llama 3) si contrainte data privacy forte.

### Cas d'usage :
1.  **Parsing Vocal (Speech-to-Text -> JSON)** :
    - *Input* : "Décale mon point avec Marc à demain, même heure."
    - *Action* : Recherche événement "Marc" aujourd'hui -> Update `start_time` +24h.
2.  **Résumés Intelligents** :
    - *Input* : Liste événements J + J+1.
    - *Prompt* : "Génère un résumé de 3 lignes max pour le briefing matinal, ton humoristique."
    - *Output* : "Grosse journée : Client King à 10h (ne sois pas en retard !), suivi du marketing. Soirée libre, profite !"
3.  **Analyse de Surcharge** :
    - Le LLM analyse la "densité cognitive" (bcp de sujets différents vs un seul bloc) pour suggérer des pauses.
