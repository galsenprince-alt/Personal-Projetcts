USE ProjetDeLocationDauto;
GO

-----Déclencheur( change la disponibilité du véhicule dès qu'un contrat est signé)-----

CREATE OR ALTER TRIGGER trg_vehicule_en_location
ON contrat        -- s'applique sur la table contrat
AFTER INSERT      -- se déclenche APRÈS un INSERT
AS
BEGIN
    UPDATE vehicule
    SET statut_disponibilite = 'en_location'
    WHERE id_vehicule IN (SELECT id_vehicule FROM inserted);
    --                                            ^^^^^^^^
    --                    "inserted" est une table temporaire
    --                    créée automatiquement par SQL Server
    --                    qui contient la nouvelle ligne insérée
END;
GO


----- La Fonction (calculer le prix d'un contrat avec les options)-----

CREATE OR ALTER FUNCTION fn_cout_total_reservation(@id_reservation INT)
--                                                 ^^^^^^^^^^^^^^^^
--                                        paramètre d'entrée (comme un argument)
RETURNS DECIMAL(10,2)   -- type de valeur retournée
AS
BEGIN
    DECLARE @prix_contrat DECIMAL(10,2);  -- déclarer une variable
    DECLARE @prix_options DECIMAL(10,2);  -- déclarer une variable

    SELECT @prix_contrat = prix           -- stocker le résultat dans la variable
    FROM contrat
    WHERE id_reservation = @id_reservation;

    SELECT @prix_options = ISNULL(SUM(o.prix), 0)
    --                     ^^^^^^
    --                     si aucune option, retourne 0 au lieu de NULL
    FROM reservation_option ro
    JOIN option_location o ON ro.id_option = o.id
    WHERE ro.id_reservation = @id_reservation;

    RETURN @prix_contrat + @prix_options;  -- retourner le résultat
END;
GO

--La Procèdure stockée
CREATE OR ALTER PROCEDURE sp_retour_vehicule
    @id_contrat  INT,    -- paramètre 1 : quel contrat se termine
    @nouveau_km  INT     -- paramètre 2 : kilométrage au retour
AS
BEGIN
    DECLARE @id_vehicule INT;

    -- Étape 1 : trouver quel véhicule est lié au contrat
    SELECT @id_vehicule = id_vehicule
    FROM contrat
    WHERE id_contrat = @id_contrat;

    -- Étape 2 : mettre à jour le véhicule
    UPDATE vehicule
    SET kilometrage = @nouveau_km,
        statut_disponibilite = 'disponible'  -- redevient disponible
    WHERE id_vehicule = @id_vehicule;

    -- Étape 3 : afficher un résumé du retour
    SELECT 
        v.marque + ' ' + v.modele  AS vehicule,
        v.kilometrage              AS nouveau_kilometrage,
        v.statut_disponibilite     AS statut
    FROM vehicule v
    WHERE v.id_vehicule = @id_vehicule;
END;