-- =================================================================
-- PROJET D'ANALYSE IMMOBILIÈRE - BASE DE DONNÉES DATAIMMO
-- =================================================================
-- Auteur: [Votre Nom]
-- Date: [Date de création]
-- Description: Analyse complète des données immobilières françaises
-- Période d'analyse: Année 2020 (focus 1er semestre)
-- =================================================================

-- -----------------------------------------------------------------
-- REQUÊTE 1: VOLUME GLOBAL DES TRANSACTIONS
-- Objectif: Compter le nombre total d'appartements vendus au 1er semestre 2020
-- -----------------------------------------------------------------
SELECT COUNT(*) AS nombre_total_appartements
FROM bien
JOIN vente ON bien.Id_bien = vente.Id_bien
WHERE bien.type_local = 'Appartement'
AND vente.date_mutation BETWEEN '2020/01/01' AND '2020/06/30';

-- -----------------------------------------------------------------
-- REQUÊTE 2: RÉPARTITION GÉOGRAPHIQUE PAR RÉGION
-- Objectif: Analyser la distribution des ventes d'appartements par région
-- -----------------------------------------------------------------
SELECT region.reg_nom, COUNT(*) AS nombre_appartements_par_region
FROM bien
JOIN vente ON bien.id_bien = vente.id_bien
JOIN commune ON bien.codedep_codecom = commune.codedep_codecom
JOIN region ON commune.cod_reg = region.reg_code
WHERE bien.type_local = 'Appartement'
AND vente.date_mutation BETWEEN '2020/01/01' AND '2020/06/30'
GROUP BY region.reg_code, region.reg_nom
ORDER BY nombre_appartements_par_region DESC;

-- -----------------------------------------------------------------
-- REQUÊTE 3: ANALYSE PAR NOMBRE DE PIÈCES
-- Objectif: Calculer la proportion de ventes selon le nombre de pièces
-- -----------------------------------------------------------------
SELECT bien.total_piece,
       COUNT(vente.id_bien) AS nombre_ventes_proportion,
       ROUND(COUNT(vente.id_bien) * 100.0 / 
             (SELECT COUNT(vente.id_bien)
              FROM vente
              JOIN bien ON vente.id_bien = bien.id_bien
              WHERE bien.type_local = 'Appartement'
              AND vente.date_mutation BETWEEN '2020/01/01' AND '2020/06/30'), 2) AS proportion_ventes
FROM bien
LEFT JOIN vente ON bien.id_bien = vente.id_bien
WHERE bien.type_local = 'Appartement'
AND vente.date_mutation BETWEEN '2020/01/01' AND '2020/06/30'
GROUP BY bien.total_piece
ORDER BY bien.total_piece;

-- -----------------------------------------------------------------
-- REQUÊTE 4: TOP 10 DÉPARTEMENTS - PRIX AU M²
-- Objectif: Identifier les départements avec les prix au m² les plus élevés
-- -----------------------------------------------------------------
SELECT commune.code_dep,
       ROUND(AVG(vente.valeur/bien.surface_carrez), 2) AS prix_m2_moyen
FROM bien
JOIN commune ON bien.codedep_codecom = commune.codedep_codecom
JOIN vente ON bien.Id_bien = vente.Id_bien
WHERE bien.surface_carrez > 0  -- Éviter division par zéro
AND vente.valeur > 0           -- Éviter valeurs aberrantes
GROUP BY commune.code_dep
HAVING COUNT(*) >= 10          -- Minimum 10 ventes pour statistique fiable
ORDER BY prix_m2_moyen DESC
LIMIT 10;

-- -----------------------------------------------------------------
-- REQUÊTE 5: PRIX MOYEN MAISONS ÎLE-DE-FRANCE
-- Objectif: Calculer le prix moyen au m² des maisons en Île-de-France
-- -----------------------------------------------------------------
SELECT A.type_local,
       ROUND(SUM(B.valeur)/SUM(A.surface_carrez), 0) AS prix_moyen_m2_maison_idf,
       COUNT(*) AS nombre_transactions,
       ROUND(AVG(B.valeur), 0) AS valeur_moyenne_transaction
FROM bien A
JOIN vente B ON A.Id_bien = B.Id_bien
JOIN commune C ON A.codedep_codecom = C.codedep_codecom
WHERE A.type_local = 'Maison'
AND A.surface_carrez IS NOT NULL
AND B.valeur IS NOT NULL
AND C.cod_reg = '11';  -- Code région Île-de-France

-- -----------------------------------------------------------------
-- REQUÊTE 6: CLASSEMENT DES APPARTEMENTS LES PLUS CHERS
-- Objectif: Ranking des appartements par valeur décroissante avec contexte géographique
-- -----------------------------------------------------------------
SELECT RANK() OVER (ORDER BY vente.valeur DESC) AS classement,
       bien.codedep_codecom,
       bien.surface_carrez,
       vente.valeur,
       ROUND(vente.valeur/bien.surface_carrez, 2) AS prix_m2,
       commune.cod_reg,
       region.reg_nom
FROM vente
INNER JOIN bien ON vente.id_bien = bien.id_bien
INNER JOIN commune ON bien.codedep_codecom = commune.codedep_codecom
INNER JOIN region ON commune.cod_reg = region.reg_code
WHERE bien.type_local = 'Appartement'
AND bien.surface_carrez > 0
ORDER BY vente.valeur DESC, commune.cod_reg
LIMIT 10;

-- -----------------------------------------------------------------
-- REQUÊTE 7: ÉVOLUTION TRIMESTRIELLE DES VENTES (IMPACT COVID-19)
-- Objectif: Comparer les ventes avant et après avril 2020
-- -----------------------------------------------------------------
WITH tri_1 AS (
    SELECT COUNT(Id_vente) AS premier_tri_1
    FROM vente
    WHERE date_mutation < '2020/04/01'
    AND date_mutation >= '2020/01/01'
),
tri_2 AS (
    SELECT COUNT(Id_vente) AS second_tri_1
    FROM vente
    WHERE date_mutation >= '2020/04/01'
    AND date_mutation < '2020/07/01'
)
SELECT 
    tri_1.premier_tri_1 AS ventes_jan_mars_2020,
    tri_2.second_tri_1 AS ventes_avr_juin_2020,
    ROUND(((tri_2.second_tri_1 - tri_1.premier_tri_1) / tri_1.premier_tri_1) * 100, 2) AS taux_evolution_percent
FROM tri_1, tri_2;

-- -----------------------------------------------------------------
-- REQUÊTE 8: ANALYSE DES GRANDS APPARTEMENTS PAR RÉGION
-- Objectif: Prix au m² des appartements de plus de 4 pièces par région
-- -----------------------------------------------------------------
SELECT bien.codedep_codecom,
       commune.cod_reg,
       region.reg_nom,
       COUNT(*) AS nombre_transactions,
       ROUND(AVG(vente.valeur / bien.surface_carrez), 2) AS prix_metre_carre_moyen,
       ROUND(MIN(vente.valeur / bien.surface_carrez), 2) AS prix_m2_min,
       ROUND(MAX(vente.valeur / bien.surface_carrez), 2) AS prix_m2_max
FROM vente
INNER JOIN bien ON vente.id_bien = bien.id_bien
JOIN commune ON bien.codedep_codecom = commune.codedep_codecom
INNER JOIN region ON commune.cod_reg = region.reg_code
WHERE bien.type_local = 'Appartement'
AND bien.total_piece > 4
AND bien.surface_carrez > 0
GROUP BY bien.codedep_codecom, commune.cod_reg, region.reg_nom
HAVING COUNT(*) >= 5  -- Minimum 5 transactions pour fiabilité
ORDER BY prix_metre_carre_moyen DESC;

-- -----------------------------------------------------------------
-- REQUÊTE 9: COMMUNES TRÈS ACTIVES (Q1 2020)
-- Objectif: Identifier les communes avec forte activité transactionnelle
-- -----------------------------------------------------------------
SELECT commune.nom_commune,
       commune.code_dep,
       COUNT(*) AS nombre_ventes,
       ROUND(AVG(vente.valeur), 0) AS valeur_moyenne,
       ROUND(SUM(vente.valeur), 0) AS volume_total_transactions
FROM vente
INNER JOIN bien ON vente.id_bien = bien.id_bien
INNER JOIN commune ON bien.codedep_codecom = commune.codedep_codecom
WHERE vente.date_mutation BETWEEN '2020-01-01' AND '2020-03-31'
GROUP BY commune.nom_commune, commune.code_dep
HAVING COUNT(*) >= 50
ORDER BY nombre_ventes DESC
LIMIT 20;

-- -----------------------------------------------------------------
-- REQUÊTE 10: COMPARAISON PRIX 2 VS 3 PIÈCES
-- Objectif: Analyser l'écart de prix entre appartements 2 et 3 pièces
-- -----------------------------------------------------------------
SELECT 
    ROUND(AVG(CASE WHEN bien.total_piece = 2 THEN vente.valeur / bien.surface_carrez END), 2) AS prix_m2_2_pieces,
    ROUND(AVG(CASE WHEN bien.total_piece = 3 THEN vente.valeur / bien.surface_carrez END), 2) AS prix_m2_3_pieces,
    COUNT(CASE WHEN bien.total_piece = 2 THEN 1 END) AS nb_ventes_2_pieces,
    COUNT(CASE WHEN bien.total_piece = 3 THEN 1 END) AS nb_ventes_3_pieces,
    ROUND(((AVG(CASE WHEN bien.total_piece = 3 THEN vente.valeur / bien.surface_carrez END) - 
            AVG(CASE WHEN bien.total_piece = 2 THEN vente.valeur / bien.surface_carrez END)) / 
            AVG(CASE WHEN bien.total_piece = 2 THEN vente.valeur / bien.surface_carrez END)) * 100, 2) AS difference_pourcentage
FROM vente
INNER JOIN bien ON vente.id_bien = bien.id_bien
WHERE bien.type_local = 'Appartement'
AND bien.total_piece IN (2, 3)
AND bien.surface_carrez > 0;

-- -----------------------------------------------------------------
-- REQUÊTE 11: TOP 3 COMMUNES PAR DÉPARTEMENT SÉLECTIONNÉ
-- Objectif: Identifier les 3 meilleures communes de départements stratégiques
-- -----------------------------------------------------------------
WITH TopCommunes AS (
    SELECT commune.code_dep,
           commune.com_nom,
           COUNT(*) AS nb_transactions,
           ROUND(AVG(vente.valeur), 2) AS moyenne_valeur_fonciere,
           ROUND(AVG(vente.valeur / bien.surface_carrez), 2) AS prix_m2_moyen,
           ROW_NUMBER() OVER (PARTITION BY commune.code_dep ORDER BY AVG(vente.valeur) DESC) AS row_num
    FROM vente
    INNER JOIN bien ON vente.id_bien = bien.id_bien
    INNER JOIN commune ON bien.codedep_codecom = commune.codedep_codecom
    WHERE commune.code_dep IN ('06', '13', '33', '59', '69')  -- Alpes-Mar., Bouches-Rhône, Gironde, Nord, Rhône
    AND bien.surface_carrez > 0
    GROUP BY commune.code_dep, commune.com_nom
    HAVING COUNT(*) >= 10  -- Minimum 10 transactions
)
SELECT code_dep,
       com_nom,
       nb_transactions,
       moyenne_valeur_fonciere,
       prix_m2_moyen
FROM TopCommunes
WHERE row_num <= 3
ORDER BY code_dep, row_num;

-- -----------------------------------------------------------------
-- REQUÊTE 12: ANALYSE DÉTAILLÉE GRANDS APPARTEMENTS (DUPLICATE OPTIMISÉE)
-- Objectif: Version améliorée de l'analyse des appartements > 4 pièces
-- -----------------------------------------------------------------
SELECT region.reg_nom,
       COUNT(*) AS nombre_transactions,
       ROUND(AVG(vente.valeur / bien.surface_carrez), 2) AS prix_metre_carre_moyen,
       ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY vente.valeur / bien.surface_carrez), 2) AS prix_m2_median,
       ROUND(STDDEV(vente.valeur / bien.surface_carrez), 2) AS ecart_type_prix_m2
FROM vente
INNER JOIN bien ON vente.id_bien = bien.id_bien
JOIN commune ON bien.codedep_codecom = commune.codedep_codecom
INNER JOIN region ON commune.cod_reg = region.reg_code
WHERE bien.type_local = 'Appartement'
AND bien.total_piece > 4
AND bien.surface_carrez > 0
GROUP BY region.reg_nom
HAVING COUNT(*) >= 20  -- Minimum 20 transactions pour robustesse statistique
ORDER BY prix_metre_carre_moyen DESC;

-- =================================================================
-- REQUÊTES D'ANALYSE COMPLÉMENTAIRES
-- =================================================================

-- -----------------------------------------------------------------
-- BONUS 1: ÉVOLUTION MENSUELLE DES PRIX 2020
-- -----------------------------------------------------------------
SELECT EXTRACT(MONTH FROM vente.date_mutation) AS mois,
       COUNT(*) AS nb_ventes,
       ROUND(AVG(vente.valeur), 0) AS prix_moyen,
       ROUND(AVG(vente.valeur / bien.surface_carrez), 2) AS prix_m2_moyen
FROM vente
INNER JOIN bien ON vente.id_bien = bien.id_bien
WHERE EXTRACT(YEAR FROM vente.date_mutation) = 2020
AND bien.type_local = 'Appartement'
AND bien.surface_carrez > 0
GROUP BY EXTRACT(MONTH FROM vente.date_mutation)
ORDER BY mois;

-- -----------------------------------------------------------------
-- BONUS 2: ANALYSE DE LA DISPERSION DES PRIX PAR RÉGION
-- -----------------------------------------------------------------
SELECT region.reg_nom,
       COUNT(*) AS nb_transactions,
       ROUND(AVG(vente.valeur), 0) AS prix_moyen,
       ROUND(MIN(vente.valeur), 0) AS prix_min,
       ROUND(MAX(vente.valeur), 0) AS prix_max,
       ROUND(STDDEV(vente.valeur), 0) AS ecart_type,
       ROUND((STDDEV(vente.valeur) / AVG(vente.valeur)) * 100, 2) AS coefficient_variation
FROM vente
INNER JOIN bien ON vente.id_bien = bien.id_bien
JOIN commune ON bien.codedep_codecom = commune.codedep_codecom
INNER JOIN region ON commune.cod_reg = region.reg_code
WHERE bien.type_local = 'Appartement'
GROUP BY region.reg_nom
HAVING COUNT(*) >= 100
ORDER BY coefficient_variation DESC;

-- =================================================================
-- FIN DU FICHIER D'ANALYSE DATAIMMO
-- =================================================================