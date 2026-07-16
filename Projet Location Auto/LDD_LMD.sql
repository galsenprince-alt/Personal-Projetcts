-- ============================================================
--  SCHÉMA + REMPLISSAGE – Location de véhicules (SQL Server)
-- ============================================================

-- ------------------------------------------------------------
-- 0. CRÉATION DE LA BASE
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'ProjetDeLocationDauto')
BEGIN

  CREATE DATABASE ProjetDeLocationDauto;
END;
GO

USE ProjetDeLocationDauto;
GO

-- Supprimer les tables si elles existent déjà (ordre enfants → parents)
DROP TABLE IF EXISTS reservation_option;
DROP TABLE IF EXISTS incident;
DROP TABLE IF EXISTS maintenance;
DROP TABLE IF EXISTS contrat;
DROP TABLE IF EXISTS reservation;
DROP TABLE IF EXISTS option_location;
DROP TABLE IF EXISTS vehicule;
DROP TABLE IF EXISTS client;
DROP TABLE IF EXISTS agence;
GO

-- ------------------------------------------------------------
-- TABLES
-- ------------------------------------------------------------

CREATE TABLE agence (
    id_agence  INT           PRIMARY KEY IDENTITY(1,1),
    nom_agence VARCHAR(100)  NOT NULL,
    ville      VARCHAR(100)  NOT NULL,
    adresse    VARCHAR(255)  NOT NULL,
    telephone  VARCHAR(20)
);
GO

CREATE TABLE client (
    id_client              INT          PRIMARY KEY IDENTITY(1,1),
    nom                    VARCHAR(100) NOT NULL,
    prenom                 VARCHAR(100) NOT NULL,
    adresse_courriel       VARCHAR(150) NOT NULL UNIQUE,
    numero_permis          VARCHAR(50)  NOT NULL UNIQUE,
    date_expiration_permis DATE         NOT NULL,
    telephone              VARCHAR(20)
);
GO

CREATE TABLE vehicule (
    id_vehicule          INT          PRIMARY KEY IDENTITY(1,1),
    type_vehicule        VARCHAR(50)  NOT NULL,
    marque               VARCHAR(100) NOT NULL,
    modele               VARCHAR(100) NOT NULL,
    annee                SMALLINT     NOT NULL,       -- YEAR n'existe pas en SQL Server
    type_moteur          VARCHAR(50),
    kilometrage          INT          DEFAULT 0,
    carburant            VARCHAR(50),
    capacite_passager    INT,
    statut_disponibilite VARCHAR(30)  NOT NULL DEFAULT 'disponible',
    id_agence            INT          NOT NULL,
    CONSTRAINT fk_vehicule_agence FOREIGN KEY (id_agence) REFERENCES agence(id_agence)
);
GO

CREATE TABLE option_location (
    id          INT           PRIMARY KEY IDENTITY(1,1),
    nom         VARCHAR(100)  NOT NULL,
    description NVARCHAR(MAX),
    prix        DECIMAL(10,2) NOT NULL
);
GO

CREATE TABLE reservation (
    id_reservation      INT          PRIMARY KEY IDENTITY(1,1),
    numero_confirmation VARCHAR(50)  NOT NULL UNIQUE,
    date_reservation    DATE         NOT NULL,   -- "date" est un mot réservé → renommé
    date_debut          DATE         NOT NULL,
    date_fin            DATE         NOT NULL,
    statut              VARCHAR(30)  NOT NULL DEFAULT 'en_attente',
    id_client           INT          NOT NULL,
    CONSTRAINT fk_reservation_client FOREIGN KEY (id_client) REFERENCES client(id_client)
);
GO

CREATE TABLE contrat (
    id_contrat     INT           PRIMARY KEY IDENTITY(1,1),
    date_debut     DATE          NOT NULL,
    date_fin       DATE          NOT NULL,
    conditions     NVARCHAR(MAX),
    prix           DECIMAL(10,2) NOT NULL,
    id_reservation INT           NOT NULL UNIQUE,
    id_vehicule    INT           NOT NULL,
    agence_depart  INT           NOT NULL,
    agence_retour  INT           NOT NULL,
    CONSTRAINT fk_contrat_reservation  FOREIGN KEY (id_reservation) REFERENCES reservation(id_reservation),
    CONSTRAINT fk_contrat_vehicule     FOREIGN KEY (id_vehicule)    REFERENCES vehicule(id_vehicule),
    CONSTRAINT fk_contrat_agence_dep   FOREIGN KEY (agence_depart)  REFERENCES agence(id_agence),
    CONSTRAINT fk_contrat_agence_ret   FOREIGN KEY (agence_retour)  REFERENCES agence(id_agence)
);
GO

CREATE TABLE reservation_option (
    id_reservation INT NOT NULL,
    id_option      INT NOT NULL,
    PRIMARY KEY (id_reservation, id_option),
    CONSTRAINT fk_ro_reservation FOREIGN KEY (id_reservation) REFERENCES reservation(id_reservation),
    CONSTRAINT fk_ro_option      FOREIGN KEY (id_option)      REFERENCES option_location(id)
);
GO

CREATE TABLE incident (
    id_incident             INT           PRIMARY KEY IDENTITY(1,1),
    type_incident   VARCHAR(100)  NOT NULL,   -- "type" est un mot réservé → renommé
    date_incident   DATE          NOT NULL,
    description     NVARCHAR(MAX),
    cout_reparation DECIMAL(10,2),
    id_vehicule     INT           NOT NULL,
    id_contrat      INT,
    CONSTRAINT fk_incident_vehicule FOREIGN KEY (id_vehicule) REFERENCES vehicule(id_vehicule),
    CONSTRAINT fk_incident_contrat  FOREIGN KEY (id_contrat)  REFERENCES contrat(id_contrat)
);
GO

CREATE TABLE maintenance (
    id_maintenance INT           PRIMARY KEY IDENTITY(1,1),
    type_maintenance VARCHAR(100) NOT NULL,   -- "type" est un mot réservé → renommé
    date_maintenance DATE         NOT NULL,   -- "date" est un mot réservé → renommé
    description    NVARCHAR(MAX),
    cout           DECIMAL(10,2),
    id_vehicule    INT           NOT NULL,
    CONSTRAINT fk_maintenance_vehicule FOREIGN KEY (id_vehicule) REFERENCES vehicule(id_vehicule)
);
GO

-- ============================================================
--  PROCÉDURES DE REMPLISSAGE
-- ============================================================

-- ------------------------------------------------------------
-- 1. AGENCES  (8 tuples)
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE seed_agences AS
BEGIN
    INSERT INTO agence (nom_agence, ville, adresse, telephone) VALUES
      ('AutoLocation Montreal Centre',   'Montreal',       '1250 boul. Rene-Levesque O.',  '514-555-0101'),
      ('AutoLocation Montreal Aeroport', 'Montreal',       '975 boul. Romeo-Vachon N.',    '514-555-0102'),
      ('AutoLocation Quebec City',       'Quebec',         '500 Grande Allee E.',          '418-555-0201'),
      ('AutoLocation Laval',             'Laval',          '3030 boul. Le Carrefour',      '450-555-0301'),
      ('AutoLocation Sherbrooke',        'Sherbrooke',     '1800 rue King O.',             '819-555-0401'),
      ('AutoLocation Trois-Rivieres',    'Trois-Rivieres', '4200 boul. des Forges',        '819-555-0501'),
      ('AutoLocation Gatineau',          'Gatineau',       '250 boul. Greber',             '819-555-0601'),
      ('AutoLocation Longueuil',         'Longueuil',      '85 ch. Chambly',               '450-555-0701');
END;
GO

-- ------------------------------------------------------------
-- 2. CLIENTS  (12 tuples)
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE seed_clients AS
BEGIN
    INSERT INTO client (nom, prenom, adresse_courriel, numero_permis, date_expiration_permis, telephone) VALUES
      ('Tremblay',  'Luc',       'luc.tremblay@courriel.ca',      'Q1234-567890-00', '2027-08-15', '514-555-1001'),
      ('Gagnon',    'Marie',     'marie.gagnon@gmail.com',        'Q2345-678901-00', '2026-03-22', '418-555-1002'),
      ('Roy',       'Jean-Paul', 'jeanpaul.roy@hotmail.com',      'Q3456-789012-00', '2028-11-30', '450-555-1003'),
      ('Cote',      'Sophie',    'sophie.cote@outlook.com',       'Q4567-890123-00', '2025-12-01', '819-555-1004'),
      ('Bouchard',  'Pierre',    'pierre.bouchard@yahoo.ca',      'Q5678-901234-00', '2029-05-19', '514-555-1005'),
      ('Lavoie',    'Isabelle',  'isabelle.lavoie@courriel.ca',   'Q6789-012345-00', '2027-01-10', '418-555-1006'),
      ('Fortin',    'Michel',    'michel.fortin@gmail.com',       'Q7890-123456-00', '2026-07-28', '450-555-1007'),
      ('Gauthier',  'Nathalie',  'nathalie.gauthier@hotmail.com', 'Q8901-234567-00', '2028-04-14', '819-555-1008'),
      ('Morin',     'Francois',  'francois.morin@outlook.com',    'Q9012-345678-00', '2027-09-03', '514-555-1009'),
      ('Landry',    'Emilie',    'emilie.landry@courriel.ca',     'Q0123-456789-00', '2026-02-17', '418-555-1010'),
      ('Pelletier', 'David',     'david.pelletier@gmail.com',     'Q1122-334455-00', '2029-10-25', '450-555-1011'),
      ('Lefebvre',  'Caroline',  'caroline.lefebvre@yahoo.ca',    'Q2233-445566-00', '2027-06-08', '819-555-1012');
END;
GO

-- ------------------------------------------------------------
-- 3. VÉHICULES  (15 tuples)
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE seed_vehicules AS
BEGIN
    INSERT INTO vehicule (type_vehicule, marque, modele, annee, type_moteur, kilometrage, carburant, capacite_passager, statut_disponibilite, id_agence) VALUES
      ('Berline',      'Toyota',     'Camry',     2022, 'Thermique',  28500, 'Essence',    5, 'disponible',  1),
      ('VUS',          'Honda',      'CR-V',      2023, 'Hybride',    15200, 'Hybride',    5, 'disponible',  1),
      ('Economique',   'Hyundai',    'Accent',    2021, 'Thermique',  52000, 'Essence',    5, 'en_location', 1),
      ('VUS',          'Toyota',     'RAV4',      2023, 'Hybride',    12000, 'Hybride',    5, 'disponible',  2),
      ('Luxe',         'BMW',        '5 Series',  2022, 'Thermique',  22000, 'Essence',    5, 'disponible',  2),
      ('Fourgonnette', 'Chrysler',   'Pacifica',  2022, 'Hybride',    31000, 'Hybride',    7, 'en_location', 2),
      ('Berline',      'Honda',      'Civic',     2023, 'Thermique',   9500, 'Essence',    5, 'disponible',  3),
      ('Camionnette',  'Chevrolet',  'Silverado', 2023, 'Thermique',   7800, 'Essence',    5, 'disponible',  3),
      ('Electrique',   'Tesla',      'Model 3',   2023, 'Electrique',  8000, 'Electrique', 5, 'disponible',  4),
      ('Berline',      'Volkswagen', 'Jetta',     2021, 'Thermique',  55000, 'Essence',    5, 'en_location', 4),
      ('VUS',          'Ford',       'Escape',    2023, 'Hybride',    11500, 'Hybride',    5, 'disponible',  5),
      ('Luxe',         'Mercedes',   'Classe C',  2022, 'Thermique',  19000, 'Essence',    5, 'disponible',  5),
      ('Camionnette',  'Ram',        '1500',      2022, 'Thermique',  37000, 'Essence',    5, 'disponible',  6),
      ('Electrique',   'Chevrolet',  'Bolt EV',   2023, 'Electrique',  5500, 'Electrique', 5, 'disponible',  7),
      ('VUS',          'Hyundai',    'Tucson',    2023, 'Hybride',    10200, 'Hybride',    5, 'disponible',  8);
END;
GO

-- ------------------------------------------------------------
-- 4. OPTIONS  (6 tuples)
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE seed_options AS
BEGIN
    INSERT INTO option_location (nom, description, prix) VALUES
      ('GPS',                    'Systeme de navigation GPS integre',             9.99),
      ('Siege bebe',             'Siege pour enfant homologue',                   7.50),
      ('Conducteur additionnel', 'Permet un 2e conducteur autorise',             12.00),
      ('Protection collision',   'Couverture dommages collision sans franchise', 19.99),
      ('Roadside Assistance',    'Assistance routiere 24h/24 7j/7',              6.00),
      ('Reservoir prepaye',      'Reservoir plein a la prise, retour vide OK',   35.00);
END;
GO

-- ------------------------------------------------------------
-- 5. RÉSERVATIONS  (15 tuples)
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE seed_reservations AS
BEGIN
    INSERT INTO reservation (numero_confirmation, date_reservation, date_debut, date_fin, statut, id_client) VALUES
      ('CONF-2024-0001', '2024-01-05', '2024-01-10', '2024-01-15', 'confirmee',  1),
      ('CONF-2024-0002', '2024-01-12', '2024-01-18', '2024-01-22', 'confirmee',  2),
      ('CONF-2024-0003', '2024-02-01', '2024-02-10', '2024-02-14', 'annulee',    3),
      ('CONF-2024-0004', '2024-02-15', '2024-02-20', '2024-02-25', 'confirmee',  4),
      ('CONF-2024-0005', '2024-02-28', '2024-03-05', '2024-03-10', 'confirmee',  5),
      ('CONF-2024-0006', '2024-03-10', '2024-03-20', '2024-03-27', 'annulee',    6),
      ('CONF-2024-0007', '2024-03-18', '2024-04-01', '2024-04-07', 'confirmee',  7),
      ('CONF-2024-0008', '2024-04-05', '2024-04-12', '2024-04-18', 'confirmee',  8),
      ('CONF-2024-0009', '2024-05-01', '2024-05-10', '2024-05-17', 'confirmee',  9),
      ('CONF-2024-0010', '2024-05-25', '2024-06-01', '2024-06-08', 'confirmee', 10),
      ('CONF-2024-0011', '2024-06-14', '2024-06-20', '2024-06-28', 'confirmee', 11),
      ('CONF-2024-0012', '2024-07-01', '2024-07-10', '2024-07-20', 'confirmee', 12),
      ('CONF-2024-0013', '2024-08-05', '2024-08-12', '2024-08-18', 'confirmee',  1),
      ('CONF-2024-0014', '2024-09-10', '2024-09-18', '2024-09-24', 'confirmee',  3),
      ('CONF-2024-0015', '2024-11-01', '2024-11-08', '2024-11-15', 'en_attente', 5);
END;
GO

-- ------------------------------------------------------------
-- 6. CONTRATS  (13 tuples — sans les 2 réservations annulées)
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE seed_contrats AS
BEGIN
    INSERT INTO contrat (date_debut, date_fin, conditions, prix, id_reservation, id_vehicule, agence_depart, agence_retour) VALUES
      ('2024-01-10', '2024-01-15', 'Retour avec plein. Franchise: 500$.',  287.50,  1,  1, 1, 1),
      ('2024-01-18', '2024-01-22', 'Retour avec plein. Franchise: 500$.',  220.00,  2,  4, 2, 2),
      ('2024-02-20', '2024-02-25', 'Retour avec plein. Franchise: 500$.',  262.50,  4,  9, 4, 4),
      ('2024-03-05', '2024-03-10', 'Retour avec plein. Franchise: 500$.',  249.95,  5, 11, 5, 5),
      ('2024-04-01', '2024-04-07', 'Retour avec plein. Franchise: 500$.',  312.00,  7, 14, 7, 7),
      ('2024-04-12', '2024-04-18', 'Retour avec plein. Franchise: 500$.',  360.00,  8,  2, 1, 2),
      ('2024-05-10', '2024-05-17', 'Retour avec plein. Franchise: 500$.',  392.00,  9,  6, 2, 3),
      ('2024-06-01', '2024-06-08', 'Retour avec plein. Franchise: 500$.',  415.00, 10, 12, 5, 5),
      ('2024-06-20', '2024-06-28', 'Retour avec plein. Franchise: 500$.',  480.00, 11,  5, 2, 1),
      ('2024-07-10', '2024-07-20', 'Retour avec plein. Franchise: 500$.',  620.00, 12, 10, 4, 5),
      ('2024-08-12', '2024-08-18', 'Retour avec plein. Franchise: 500$.',  324.00, 13,  3, 1, 1),
      ('2024-09-18', '2024-09-24', 'Retour avec plein. Franchise: 500$.',  366.00, 14,  8, 3, 4),
      ('2024-11-08', '2024-11-15', 'Retour avec plein. Franchise: 500$.',  357.00, 15,  1, 1, 1);
END;
GO

-- ------------------------------------------------------------
-- 7. OPTIONS PAR RÉSERVATION  (18 tuples)
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE seed_reservation_options AS
BEGIN
    INSERT INTO reservation_option (id_reservation, id_option) VALUES
      (1, 1),(1, 4),
      (2, 1),(2, 3),
      (4, 2),(4, 4),
      (5, 5),
      (7, 1),(7, 6),
      (8, 3),(8, 4),
      (9, 1),(9, 2),
      (10,4),(10,5),
      (11,1),(11,3),
      (12,6);
END;
GO

-- ------------------------------------------------------------
-- 8. INCIDENTS  (7 tuples)
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE seed_incidents AS
BEGIN
    -- id_incident est IDENTITY(1,1) : ne pas l'inclure dans la liste de colonnes
    INSERT INTO incident (type_incident, date_incident, description, cout_reparation, id_vehicule, id_contrat) VALUES
      ('Accrochage mineur', '2024-01-14', 'Rayure sur aile avant gauche lors du stationnement.',   450.00,  1,  1),
      ('Bris vitre',        '2024-04-16', 'Pare-brise fissure suite a une projection de gravier.', 650.00,  2,  6),
      ('Panne mecanique',   '2024-05-14', 'Defaillance du demarreur, remorquage requis.',          890.00,  6,  7),
      ('Accrochage mineur', '2024-06-25', 'Bosse sur pare-chocs arriere dans un stationnement.',   380.00, 12,  8),
      ('Crevaison',         '2024-07-18', 'Pneu avant droit creve sur autoroute 20.',              120.00, 10, 10),
      ('Accrochage mineur', '2024-08-15', 'Impact leger sur portiere cote conducteur.',            310.00,  3, 11),
      ('Bris vitre',        '2024-09-22', 'Vitre laterale brisee suite a vandalisme.',             420.00,  8, 12);
END;
GO

-- ------------------------------------------------------------
-- 9. MAINTENANCES  (6 tuples)
-- ------------------------------------------------------------
CREATE OR ALTER PROCEDURE seed_maintenances AS
BEGIN
    INSERT INTO maintenance (type_maintenance, date_maintenance, description, cout, id_vehicule) VALUES
      ('Vidange huile',       '2024-01-08', 'Vidange + remplacement filtre a huile.',              89.99,  1),
      ('Inspection complete', '2024-02-20', 'Inspection 100 points + remplacement plaquettes.',   450.00,  3),
      ('Pneus ete',           '2024-04-15', 'Changement vers pneus ete Continental + equilibrage.',290.00, 4),
      ('Freins',              '2024-06-22', 'Remplacement plaquettes et disques arriere.',         540.00,  6),
      ('Pneus hiver',         '2024-11-10', 'Changement vers pneus hiver Michelin X-Ice.',        320.00,  2),
      ('Vidange huile',       '2024-10-05', 'Vidange semi-synthetique 5W-20 + filtre air.',        95.00, 14);
END;
GO

-- ============================================================
--  EXÉCUTION DE TOUTES LES PROCÉDURES
-- ============================================================
EXEC seed_agences;
EXEC seed_clients;
EXEC seed_vehicules;
EXEC seed_options;
EXEC seed_reservations;
EXEC seed_contrats;
EXEC seed_reservation_options;
EXEC seed_incidents;
EXEC seed_maintenances;
GO

-- ============================================================
--  NETTOYAGE
-- ============================================================
DROP PROCEDURE IF EXISTS seed_agences;
DROP PROCEDURE IF EXISTS seed_clients;
DROP PROCEDURE IF EXISTS seed_vehicules;
DROP PROCEDURE IF EXISTS seed_options;
DROP PROCEDURE IF EXISTS seed_reservations;
DROP PROCEDURE IF EXISTS seed_contrats;
DROP PROCEDURE IF EXISTS seed_reservation_options;
DROP PROCEDURE IF EXISTS seed_incidents;
DROP PROCEDURE IF EXISTS seed_maintenances;
GO

USE ProjetDeLocationDauto;
GO

-- Voir le contenu d'une table
SELECT * FROM agence;
SELECT * FROM client;
SELECT * FROM vehicule;
SELECT * FROM option_location;
SELECT * FROM reservation;
SELECT * FROM contrat;
SELECT * FROM reservation_option;
SELECT * FROM incident;
SELECT * FROM maintenance;