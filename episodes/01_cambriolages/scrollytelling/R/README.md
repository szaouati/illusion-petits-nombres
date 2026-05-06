# Scripts R — page scrollytelling épisode 1

Tous les SVG de la page sont régénérables depuis ces 3 scripts.

## Dépendances

```r
install.packages(c("ggplot2", "dplyr", "scales", "svglite"))
```

## Ordre d'exécution

Les scripts utilisent des chemins relatifs ; ouvre chacun dans RStudio
depuis ce dossier (`episodes/01_cambriolages/scrollytelling/R/`) ou
définis le working directory ici.

```r
source("01_scatter_layers.R")  # → ../svg/01-06_scatter_*.svg
source("02_funnel.R")           # → ../svg/07_funnel.svg
source("03_simulation.R")       # → ../svg/08-09_simulation_*.svg
```

Le fichier `10_formule.svg` est statique (formule mathématique sans
calcul) — il a été produit à part avec matplotlib pour le rendu LaTeX
(`σ ≈ √(p/n)`). Il peut être recréé en R via `latex2exp` si besoin,
mais ce n'est pas nécessaire pour la reproductibilité de l'analyse.

## Inputs requis

Les 3 CSV produits par `episode_01.qmd` :
- `../cambriolages_2024.csv`
- `../top10_brut.csv`
- `../top10_corrige.csv`

Si tu n'as pas encore rendu le `.qmd`, fais-le d'abord
(Render dans RStudio).

## Vérification de la simulation (bloc Poisson)

La graine est fixée à 42 dans `03_simulation.R`. Avec cette graine et
les paramètres p = 0,005 / n = 200, tu dois obtenir :

- 392 communes à 0 cambriolage / 1 000
- 84 communes à ≥ 15 ‰
- σ théorique = √(0,005 / 200) × 1000 = 5,00 ‰

Ces chiffres sont cités dans la page HTML — si tu modifies les
paramètres, pense à mettre à jour le texte dans `index.html`.
