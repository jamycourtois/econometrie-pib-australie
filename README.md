# Analyse Économétrique du PIB Australien

Projet d'économétrie des séries temporelles réalisé dans le cadre du Master 1 MBFA (Parcours Analyse et Modélisation des Risques) à l'Université Paris-Est Créteil (UPEC).

Ce projet porte sur l'analyse du taux de croissance du PIB réel australien et sur l'estimation d'un modèle économétrique intégrant l'effet de contagion du PIB américain.

## Données

- **Source** : OCDE (PIB nominal et déflateur du PIB)
- **Pays** : Australie et États-Unis
- **Fréquence** : trimestrielle (~175 observations, de 1980 à 2023)

## Méthodologie

### Application 1 : Tests de racine unitaire et détection des valeurs extrêmes

| Étape | Description |
|-------|-------------|
| Construction des variables | PIB réel, logarithme du PIB réel, taux de croissance trimestriel |
| Tests de racine unitaire | ADF (Augmented Dickey–Fuller), ERS (Elliott–Rothenberg–Stock), Phillips–Perron |
| Statistiques descriptives | Analyse de la distribution, test de normalité (Shapiro-Wilk, Kolmogorov-Smirnov, Anderson-Darling) |
| Détection des valeurs extrêmes | Méthode du Z-score (seuil ±3σ) et méthode de la MAD — Median Absolute Deviation (seuil ±2.5) |

**Résultat :** La série du log du PIB réel est intégrée d'ordre 1. Après différenciation, le taux de croissance est stationnaire. 21 valeurs extrêmes sont identifiées et supprimées via la méthode de la MAD (plus robuste que le Z-score pour les distributions non normales).

### Application 2 : Modèle économétrique

Le modèle estimé par MCO est le suivant :

```
ΔYt = β₀ + β₁·ΔYt₋₁ + β₂·ΔYt₋₁(USA) + εt
```

| Étape | Description |
|-------|-------------|
| Estimation par MCO | Régression du taux de croissance australien sur son retard et le retard du taux de croissance américain |
| Test de White | Homoscédasticité du terme d'erreur (non rejetée) |
| Test de Breusch-Godfrey | Absence d'autocorrélation des erreurs (non rejetée) |
| Test de Jarque-Bera | Normalité des résidus (non rejetée) |
| Estimation robuste (GMM) | Estimateur de Newey-West (non nécessaire ici, les hypothèses classiques étant respectées) |

**Résultat :** Le modèle présente un R² très faible (0,009) et des paramètres non significatifs. La sphéricité du terme d'erreur est respectée, ce qui indique que le problème provient d'une mauvaise spécification du modèle plutôt que d'une violation des hypothèses classiques. Une relation non linéaire ou un problème d'endogénéité pourraient expliquer ces résultats.

## Structure du projet

```
econometrie-pib-australie/
├── README.md
├── rapport/
│   ├── Rapport_PIB_Australie.pdf
│   └── rapport_pib_australie.tex
└── sas/
    └── analyse_pib_australie.sas
```

## Outils

- **SAS** (SAS OnDemand for Academics)
- **LaTeX** (rédaction du rapport)

## Auteurs

- Jamy Courtois
- Dieudonné Malonga
