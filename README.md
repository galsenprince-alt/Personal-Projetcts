# Personal-Projetcts

Ce repo contient deux projets: 

1. PROJET PORTFOLIO — MANDAT D'ANALYSTE D'AFFAIRES

Étude de cas : consolidation post-acquisition des données client — iA Groupe financier (TSX : IAG)
Mandat simulé à des fins de démonstration professionnelle.

PAR OÙ COMMENCER
--------------------------------------------------------------------------------
1. 00_Commencer_ici / 00_Presentation_portfolio_recruteur.docx
   → Introduction d'une page (à lire en premier).

2. L7_Rapport_final / Livrable_7_Rapport_analyste_final_iA.docx
   → Le rapport de synthèse (5 pages) : constats, recommandations, plan.

3. Les livrables 1 à 6, dans l'ordre, pour le détail.


CONTENU DU DOSSIER
--------------------------------------------------------------------------------
00_Commencer_ici/
   - Présentation portfolio (recruteur)
   - Guide de présentation orale (entrevue)

L1_Profil_corporatif_financier/
   - Profil corporatif et financier (Word) + Annexe de données (Excel)
   - Source : rapport annuel 2025, états financiers audités, S&P Capital IQ

L2_Cas_affaires/
   - Cas d'affaires (Word) + Modèle financier VAN/TRI/sensibilité (Excel)

L3_Modelisation_processus_BPMN/
   - Document d'analyse (Word) + liens vers les 2 diagrammes Lucidchart (ci-dessous)

L4_Modelisation_donnees/
   - Dictionnaire de données + règles de gestion (Excel)
   - Script SQL DDL PostgreSQL
   - ERD : lien Lucidchart (ci-dessous)

L5_Gestion_Agile/
   - Charte de projet (Word) + Backlog / risques / roadmap / RACI (Excel)

L6_Tableau_bord_KPI/
   - Catalogue KPI, données simulées, tableau de bord, guide Power BI (Excel)

L7_Rapport_final/
   - Rapport d'analyste final (Word)


DIAGRAMMES LUCIDCHART (à ouvrir dans un navigateur)
--------------------------------------------------------------------------------
L3 — BPMN AS-IS (accueil client fragmenté) :
   https://lucid.app/lucidchart/47ace71b-ab7f-4259-b6cc-f433a4e66a9e/view
L3 — BPMN TO-BE (accueil client unifié) :
   https://lucid.app/lucidchart/a098f2df-9289-4560-b4d2-f47f330ceec1/view
L4 — ERD plateforme de données client (golden record) :
   https://lucid.app/lucidchart/6891796c-4fe3-4823-b386-396cbb518278/view

Tableau monday.com (backlog à importer via + Ajouter > Importer > Excel) :
   https://galsenprinces-team.monday.com/boards/18421512071


DISCIPLINE DE DONNÉES
--------------------------------------------------------------------------------
RÉEL (sourcé)      : faits corporatifs et financiers (rapport annuel 2025,
                     états financiers audités du 17 février 2026, S&P Capital IQ).
SIMULÉ (identifié) : le mandat, les coûts, les bénéfices (hypothèses H01-H16),
                     les processus internes et les données opérationnelles.
iA Groupe financier n'est pas affilié à ce travail.
-------------------------------------------------------------------------------------------------------

2. PROJET DE LA GESTION/CRÉATION DE BASE DE DONNÉES POUR UNE COMPAGNIE DE LOCATION D'AUTO AVEC RAPPORT

 # Projet de Base de Données — Agence de Location de Véhicules

Conception et implémentation d'un système de gestion complet pour une agence de location de véhicules au Québec, incluant la gestion des réservations, des clients, de la flotte et des contrats.

---

## Contenu du projet

1. **Reformulation du projet** — description détaillée et réaliste du système
2. **Modèle entité-association (MEA)** — diagramme entité-relation couvrant toutes les entités et leurs associations
3. **Modèle relationnel** — schéma relationnel dérivé du MEA, implémenté en MySQL
4. **Création des tables SQL** — script DDL complet
5. **Données de test** — 50 à 100 tuples réalistes via procédures stockées
6. **Requêtes SQL** — une dizaine de requêtes dont 5 impliquant au moins 4 relations
7. **Déclencheur, fonction et procédure** — au moins un de chaque, testé
8. **Application fonctionnelle** — mini-application englobant plus de dix instructions SQL

---

## Structure de la base de données

### Entités principales

| Table | Description |
|---|---|
| `agence` | 8 agences réparties au Québec |
| `client` | 20 clients avec permis de conduire |
| `vehicule` | 25 véhicules de types variés |
| `reservation` | 30 réservations (confirmées, annulées, en attente) |
| `contrat` | 28 contrats liés aux réservations actives |
| `option_location` | 8 options disponibles à la location |
| `reservation_option` | Table d'association réservation ↔ options |
| `incident` | 12 incidents survenus en location |
| `maintenance` | 20 entrées de maintenance de la flotte |

### Types de véhicules disponibles

Berline, VUS, Économique, Camionnette, Fourgonnette, Luxe, Électrique.

### Options de location

GPS, siège bébé, conducteur additionnel, protection collision, assistance routière, Wi-Fi embarqué, porte-ski, réservoir prépayé.

---

## Technologies utilisées

- **SGBD :** MySQL
- **Langage :** SQL (DDL + DML + procédures/fonctions/déclencheurs)

---

## Installation et utilisation

### Prérequis

- MySQL 8.0 ou supérieur
- Un client MySQL (MySQL Workbench, DBeaver, ligne de commande, etc.)

### Étapes

```bash
# 1. Créer la base de données
mysql -u root -p -e "CREATE DATABASE location_vehicules CHARACTER SET utf8mb4;"

# 2. Créer les tables (script DDL)
mysql -u root -p location_vehicules < schema.sql

# 3. Injecter les données de test
mysql -u root -p location_vehicules < seed_data.sql

# 4. Exécuter les requêtes
mysql -u root -p location_vehicules < requetes.sql
```

---

## Agences couvertes

| # | Nom | Ville |
|---|---|---|
| 1 | AutoLocation Montréal Centre | Montréal |
| 2 | AutoLocation Montréal Aéroport | Montréal |
| 3 | AutoLocation Québec City | Québec |
| 4 | AutoLocation Laval | Laval |
| 5 | AutoLocation Sherbrooke | Sherbrooke |
| 6 | AutoLocation Trois-Rivières | Trois-Rivières |
| 7 | AutoLocation Gatineau | Gatineau |
| 8 | AutoLocation Longueuil | Longueuil |

---

## Auteur : Muhammed Faye


