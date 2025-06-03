🏠 Projet d'Analyse Immobilière - Base de Données DATAIMMO
📋 Description du Projet
Ce projet présente une analyse complète des données immobilières françaises à travers 12 requêtes SQL avancées. L'objectif est d'extraire des insights pertinents sur le marché immobilier, les tendances de prix, et les patterns géographiques des ventes immobilières.

🎯 Objectifs d'Analyse
Analyse temporelle : Évolution des ventes immobilières sur différentes périodes
Analyse géographique : Répartition des ventes par région et département
Analyse des prix : Prix au m² par zone géographique et type de bien
Analyse comparative : Comparaison entre différents types de logements
Analyse de volume : Identification des communes avec le plus de transactions
🗄️ Structure de la Base de Données
Tables Principales
bien : Informations sur les biens immobiliers (surface, type, nombre de pièces)
vente : Données des transactions (prix, date de mutation)
commune : Informations géographiques des communes
region : Données des régions françaises
Schéma Relationnel
bien ←→ vente (via id_bien)
bien ←→ commune (via codedep_codecom) 
commune ←→ region (via cod_reg/reg_code)
📊 Requêtes d'Analyse
1. Volume Global des Transactions
Objectif : Compter le nombre total d'appartements vendus au 1er semestre 2020

SELECT COUNT(*) AS nombre_total_appartements
FROM bien JOIN vente ON bien.Id_bien = vente.Id_bien
WHERE bien.type_local = 'Appartement'
AND vente.date_mutation BETWEEN '2020/01/01' AND '2020/06/30';
2. Répartition Géographique par Région
Objectif : Analyser la distribution des ventes d'appartements par région

SELECT region.reg_nom, COUNT(*) AS nombre_appartements_par_region
FROM bien JOIN vente ON bien.id_bien = vente.id_bien
JOIN commune ON bien.codedep_codecom = commune.codedep_codecom
JOIN region ON commune.cod_reg = region.reg_code
WHERE bien.type_local = 'Appartement'
AND vente.date_mutation BETWEEN '2020/01/01' AND '2020/06/30'
GROUP BY region.reg_code;
3. Analyse par Nombre de Pièces
Objectif : Calculer la proportion de ventes selon le nombre de pièces

SELECT bien.total_piece,
       COUNT(vente.id_bien) AS nombre_ventes_proportion,
       ROUND(COUNT(vente.id_bien) * 100.0 / 
             (SELECT COUNT(vente.id_bien) FROM vente 
              WHERE bien.type_local = 'Appartement'
              AND vente.date_mutation BETWEEN '2020/01/01' AND '2020/06/30'),2) AS proportion_ventes
FROM bien LEFT JOIN vente ON bien.id_bien = vente.id_bien
WHERE bien.type_local = 'Appartement'
AND vente.date_mutation BETWEEN '2020/01/01' AND '2020/06/30'
GROUP BY bien.total_piece;
4. Top 10 Départements - Prix au m²
Objectif : Identifier les départements les plus chers

SELECT commune.code_dep,
       ROUND(AVG(vente.valeur/bien.surface_carrez), 2) AS prix_m²
FROM bien JOIN commune ON bien.codedep_codecom = commune.codedep_codecom
JOIN vente ON bien.Id_bien = vente.Id_bien
GROUP BY commune.code_dep
ORDER BY prix_m² DESC
LIMIT 10;
5. Prix Moyen Maisons Île-de-France
Objectif : Calculer le prix moyen au m² des maisons en IdF

SELECT A.type_local,
       ROUND(SUM(B.valeur)/SUM(A.surface_carrez),0) AS prix_moyen_m²_maison_idf
FROM bien A JOIN vente B ON A.Id_bien=B.Id_bien
JOIN commune C ON C.cod_reg
WHERE A.type_local='Maison'
AND A.surface_carrez IS NOT NULL
AND B.valeur IS NOT NULL
AND C.cod_reg='11';
6. Classement des Appartements les Plus Chers
Objectif : Ranking des appartements par valeur décroissante

SELECT RANK() OVER (ORDER BY vente.valeur DESC) AS classement,
       bien.codedep_codecom, bien.surface_carrez, vente.valeur, commune.cod_reg
FROM vente INNER JOIN bien ON vente.id_bien = bien.id_bien
INNER JOIN commune ON bien.codedep_codecom = commune.codedep_codecom
WHERE bien.type_local = 'Appartement'
ORDER BY vente.valeur DESC, commune.cod_reg
LIMIT 10;
7. Évolution Trimestrielle des Ventes
Objectif : Comparer les ventes avant et après avril 2020 (impact COVID)

WITH tri_1 AS (
    SELECT COUNT(Id_vente) AS premier_tri_1
    FROM vente WHERE "date_mutation" < '2020/04/01'),
tri_2 AS (
    SELECT COUNT(Id_vente) AS second_tri_1
    FROM vente WHERE "date_mutation" >= '2020/04/01')
SELECT tri_1.premier_tri_1, tri_2.second_tri_1,
       ROUND(((tri_2.second_tri_1 - tri_1.premier_tri_1) / tri_1.premier_tri_1) * 100, 2) AS taux_evolution
FROM tri_1, tri_2;
8. Analyse des Grands Appartements par Région
Objectif : Prix au m² des appartements de plus de 4 pièces par région

SELECT bien.codedep_codecom, commune.cod_reg, region.reg_nom,
       ROUND(AVG(vente.valeur / bien.surface_carrez), 2) AS prix_metre_carre
FROM vente INNER JOIN bien ON vente.id_bien = bien.id_bien
JOIN commune ON bien.codedep_codecom = commune.codedep_codecom
INNER JOIN region ON commune.cod_reg = region.reg_code
WHERE bien.type_local = 'Appartement' AND bien.total_piece > 4
GROUP BY commune.cod_reg, region.reg_nom
ORDER BY prix_metre_carre DESC;
9. Communes Très Actives (Q1 2020)
Objectif : Identifier les communes avec forte activité transactionnelle

SELECT commune.nom_commune, COUNT(*) AS nombre_ventes
FROM vente INNER JOIN bien ON vente.id_bien = bien.id_bien
INNER JOIN commune ON bien.codedep_codecom = commune.codedep_codecom
WHERE vente.date_mutation BETWEEN '2020-01-01' AND '2020-03-31'
GROUP BY commune.nom_commune
HAVING COUNT(*) >= 50
ORDER BY nombre_ventes DESC;
10. Comparaison Prix 2 vs 3 Pièces
Objectif : Analyser l'écart de prix entre appartements 2 et 3 pièces

SELECT ROUND(AVG(CASE WHEN bien.total_piece = 2 THEN vente.valeur / bien.surface_carrez ELSE 0 END),2) AS prix_m2_2_pieces,
       ROUND(AVG(CASE WHEN bien.total_piece = 3 THEN vente.valeur / bien.surface_carrez ELSE 0 END),2) AS prix_m2_3_pieces,
       ROUND(((AVG(CASE WHEN bien.total_piece = 3 THEN vente.valeur / bien.surface_carrez ELSE 0 END) - 
               AVG(CASE WHEN bien.total_piece = 2 THEN vente.valeur / bien.surface_carrez ELSE 0 END)) / 
               AVG(CASE WHEN bien.total_piece = 2 THEN vente.valeur / bien.surface_carrez ELSE 0 END)) * 100, 2) AS difference_pourcentage
FROM vente INNER JOIN bien ON vente.id_bien = bien.id_bien
WHERE bien.type_local = 'Appartement' AND bien.total_piece IN (2, 3);
11. Top 3 Communes par Département
Objectif : Identifier les 3 meilleures communes de départements sélectionnés

WITH TopCommunes AS (
    SELECT commune.code_dep, commune.com_nom,
           ROUND(AVG(vente.valeur), 2) AS moyenne_valeur_fonciere,
           ROW_NUMBER() OVER (PARTITION BY commune.code_dep ORDER BY AVG(vente.valeur) DESC) AS row_num
    FROM vente INNER JOIN bien ON vente.id_bien = bien.id_bien
    INNER JOIN commune ON bien.codedep_codecom = commune.codedep_codecom
    WHERE commune.code_dep IN ('06', '13', '33', '59', '69')
    GROUP BY commune.code_dep, commune.com_nom
)
SELECT code_dep, com_nom, moyenne_valeur_fonciere
FROM TopCommunes WHERE row_num <= 3
ORDER BY code_dep, row_num;
🔧 Technologies Utilisées
SQL : Langage principal pour l'analyse des données
TerrData : Plateforme de gestion des données géospatiales
HubSpot : CRM pour le suivi des prospects immobiliers
Jira : Gestion de projet et suivi des tâches
📁 Structure du Projet
├── README.md
├── sql/
│   ├── requetes_analyse.sql
│   └── schema_creation.sql
├── data/
│   ├── dictionnaire_donnees.xlsx
│   ├── bien_et_vente.xlsx
│   └── commune_version_2.xlsx
├── docs/
│   └── documentation_technique.md
└── results/
    └── exports_resultats/
🚀 Utilisation
Cloner le repository
git clone https://github.com/[votre-username]/dataimmo-sql-analysis
cd dataimmo-sql-analysis
Importer les données
Créer la base de données selon le schéma fourni
Importer les fichiers Excel dans les tables correspondantes
Exécuter les requêtes
# Exécuter toutes les analyses
mysql -u username -p database_name < sql/requetes_analyse.sql
📈 Insights Clés
Impact COVID-19 : Analyse de l'évolution des ventes avant/après mars 2020
Disparités géographiques : Forte concentration des prix en Île-de-France
Préférences marché : Dominance des appartements 2-3 pièces
Hotspots transactionnels : Identification des communes très actives
👥 Contribution
Les contributions sont les bienvenues ! N'hésitez pas à :

Proposer de nouvelles analyses
Optimiser les requêtes existantes
Améliorer la documentation
