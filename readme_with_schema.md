## 🗄️ Architecture de la Base de Données

### 🔗 **Schéma Relationnel**

![Schéma Base de Données](images/schema_database.png)

### 📊 **Tables Principales**

| Table | Volumétrie | Description | Champs Clés |
|-------|------------|-------------|-------------|
| **BIEN** | 195K+ | Caractéristiques immobilières | `Id_bien`, `type_local`, `surface_carrez`, `total_piece` |
| **VENTE** | 195K+ | Transactions immobilières | `Id_vente`, `valeur`, `date_mutation` |
| **COMMUNE** | 35K+ | Référentiel géographique | `codedep_codecom`, `nom_commune`, `code_dep` |
| **REGION** | 18 | Régions françaises | `cod_reg`, `reg_nom` |

### 🔗 **Relations & Cardinalités**

```
REGION (1) ←→ COMMUNE (N) ←→ BIEN (N) ←→ VENTE (N)
     ↓              ↓              ↓           ↓
  reg_nom      nom_commune    type_local    valeur
              code_dep       surface_m²    date_vente
```

### 💡 **Points Clés du Modèle**

- **Normalisation 3NF** : Évite la redondance des données géographiques
- **Historisation** : Une vente = un moment dans le temps pour un bien
- **Géolocalisation** : Granularité communale pour analyses territoriales
- **Flexibilité** : Support appartements et maisons via `type_local`