# 🏠 Marché immobilier français 2020 : analyse SQL

![SQL](https://img.shields.io/badge/SQL-4479A1?style=flat-square&logo=postgresql&logoColor=white)
![Modélisation](https://img.shields.io/badge/Modélisation-draw.io-F08705?style=flat-square&logo=diagramsdotnet&logoColor=white)

> **Le contexte :** *DATAIMMO*, base de transactions immobilières 2020. Objectif : répondre en SQL aux questions qu'un promoteur, un investisseur ou une banque se posent, en pleine crise COVID.

---

## 🗄️ Modèle de données

4 tables reliées : `vente` · `bien` · `commune` · `region` (schéma relationnel dans `sql/Copie de Diagramme sans nom.drawio.html`).

## 🔎 Les 8 requêtes métier

| # | Question | Techniques SQL |
|---|---|---|
| 1 | Combien d'appartements vendus au 1er semestre 2020 ? | `COUNT`, filtres de dates |
| 2 | Comment se répartissent les ventes par région ? | `JOIN` multiples, `GROUP BY` |
| 3 | Quelle part pour chaque nombre de pièces ? | Proportions, sous-requêtes |
| 4 | Top 10 des départements les plus chers au m² | Agrégats, `ORDER BY`, `LIMIT` |
| 5 | Prix moyen au m² des maisons en Île-de-France | Filtres croisés |
| 6 | Classement des appartements les plus chers | **Fonctions de fenêtrage** (`RANK`) |
| 7 | Évolution trimestrielle : l'effet du confinement | **CTE**, comparaison de périodes |
| 8 | Prix des grands appartements (4 pièces et plus) par région | Agrégats conditionnels |

## 💡 Insights clés

- 🔴 **Choc COVID** : chute des ventes au 2e trimestre, puis rattrapage au 3e
- 🗺️ **Paris vs reste du pays** : un écart de prix au m² d'environ ×3
- 🏠 **Les 2-3 pièces dominent** le marché : le segment le plus liquide

Le détail des résultats et les recommandations par type d'acteur sont dans [`docs/results_presentation.md`](docs/results_presentation.md).

## 📁 Contenu

```
sql/sql_queries_file.sql      → les 8 requêtes commentées
sql/*.drawio.html             → schéma de la base
docs/results_presentation.md  → insights et recommandations business
```

---

<div align="center">

**Fahima Behillil** · Cheffe de projet IA & Automatisation · *Business Tech Bridge*

[LinkedIn](https://www.linkedin.com/in/fahima-be/) · [Prendre RDV (Horizons Datas)](https://calendly.com/horizonsdatas/30min) · [Tous mes projets](https://github.com/Fahima94)

</div>
