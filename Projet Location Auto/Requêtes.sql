
-- 1. Lister tous les véhicules disponibles
SELECT marque, modele, annee, type_vehicule, kilometrage
FROM vehicule
WHERE statut_disponibilite = 'disponible';

-- 2. Lister les clients avec un permis expiré
SELECT nom, prenom, adresse_courriel, date_expiration_permis
FROM client
WHERE date_expiration_permis < GETDATE();

-- 3. Nombre de véhicules par agence
SELECT a.nom_agence, COUNT(v.id_vehicule) AS nb_vehicules
FROM agence a
JOIN vehicule v ON a.id_agence = v.id_agence
GROUP BY a.nom_agence
ORDER BY nb_vehicules DESC;

-- 4. Détail complet des contrats (client, véhicule, agences départ/retour)
SELECT 
    c.nom + ' ' + c.prenom        AS client,
    v.marque + ' ' + v.modele     AS vehicule,
    co.date_debut,
    co.date_fin,
    co.prix,
    ad.nom_agence                 AS agence_depart,
    ar.nom_agence                 AS agence_retour
FROM contrat co
JOIN reservation r  ON co.id_reservation = r.id_reservation
JOIN client c       ON r.id_client       = c.id_client
JOIN vehicule v     ON co.id_vehicule    = v.id_vehicule
JOIN agence ad      ON co.agence_depart  = ad.id_agence
JOIN agence ar      ON co.agence_retour  = ar.id_agence;

-- 5. Incidents survenus avec info client, véhicule et agence
SELECT
    i.type_incident,
    i.date_incident,
    i.cout_reparation,
    v.marque + ' ' + v.modele  AS vehicule,
    a.nom_agence               AS agence,
    c.nom + ' ' + c.prenom    AS client_responsable
FROM incident i
JOIN vehicule v     ON i.id_vehicule    = v.id_vehicule
JOIN agence a       ON v.id_agence      = a.id_agence
JOIN contrat co     ON i.id_contrat     = co.id_contrat
JOIN reservation r  ON co.id_reservation = r.id_reservation
JOIN client c       ON r.id_client      = c.id_client
ORDER BY i.date_incident;

-- 6. Options choisies par chaque client pour ses réservations
SELECT
    c.nom + ' ' + c.prenom  AS client,
    r.numero_confirmation,
    o.nom                   AS option_choisie,
    o.prix
FROM client c
JOIN reservation r          ON c.id_client      = r.id_client
JOIN reservation_option ro  ON r.id_reservation = ro.id_reservation
JOIN option_location o      ON ro.id_option     = o.id
ORDER BY c.nom, r.numero_confirmation;

-- 7. Revenus totaux par agence de départ
SELECT
    a.nom_agence,
    COUNT(co.id_contrat)  AS nb_contrats,
    SUM(co.prix)          AS revenu_total
FROM contrat co
JOIN agence a       ON co.agence_depart  = a.id_agence
JOIN reservation r  ON co.id_reservation = r.id_reservation
JOIN vehicule v     ON co.id_vehicule    = v.id_vehicule
JOIN client c       ON r.id_client       = c.id_client
GROUP BY a.nom_agence
ORDER BY revenu_total DESC;

-- 8. Clients ayant eu au moins un incident, avec le coût total
SELECT
    c.nom + ' ' + c.prenom  AS client,
    COUNT(i.id_incident)              AS nb_incidents,
    SUM(i.cout_reparation)   AS cout_total_incidents
FROM client c
JOIN reservation r  ON c.id_client       = r.id_client
JOIN contrat co     ON r.id_reservation  = co.id_reservation
JOIN incident i     ON co.id_contrat     = i.id_contrat
GROUP BY c.nom, c.prenom
ORDER BY cout_total_incidents DESC;

-- 9. Historique complet de maintenance et incidents par véhicule
SELECT
    v.marque + ' ' + v.modele  AS vehicule,
    a.nom_agence               AS agence,
    'Maintenance'              AS type_evenement,
    m.type_maintenance         AS detail,
    m.date_maintenance         AS date_evenement,
    m.cout                     AS cout
FROM vehicule v
JOIN agence a       ON v.id_agence  = a.id_agence
JOIN maintenance m  ON v.id_vehicule = m.id_vehicule

UNION ALL

SELECT
    v.marque + ' ' + v.modele  AS vehicule,
    a.nom_agence               AS agence,
    'Incident'                 AS type_evenement,
    i.type_incident            AS detail,
    i.date_incident            AS date_evenement,
    i.cout_reparation          AS cout
FROM vehicule v
JOIN agence a    ON v.id_agence   = a.id_agence
JOIN incident i  ON v.id_vehicule = i.id_vehicule
ORDER BY vehicule, date_evenement;

-- 10. Réservations avec toutes leurs options et le coût total options incluses
SELECT
    r.numero_confirmation,
    c.nom + ' ' + c.prenom          AS client,
    v.marque + ' ' + v.modele       AS vehicule,
    co.prix                         AS prix_contrat,
    SUM(o.prix)                     AS total_options,
    co.prix + SUM(o.prix)           AS cout_total
FROM reservation r
JOIN client c               ON r.id_client       = c.id_client
JOIN contrat co             ON r.id_reservation  = co.id_reservation
JOIN vehicule v             ON co.id_vehicule    = v.id_vehicule
JOIN reservation_option ro  ON r.id_reservation  = ro.id_reservation
JOIN option_location o      ON ro.id_option      = o.id
GROUP BY r.numero_confirmation, c.nom, c.prenom, 
         v.marque, v.modele, co.prix
ORDER BY cout_total DESC;