# L'illusion des petits nombres

Une série de dix enquêtes publiées sur Substack, écrites entre le 2 et le 11 mai 2026.

Le sujet : la loi des petits nombres, et la manière dont la presse française la néglige systématiquement quand elle publie des classements de territoires, d'écoles, d'hôpitaux ou d'institutions.

Quand on calcule un taux à partir d'un petit échantillon, le hasard parle plus fort que la sociologie. Une commune de 200 habitants peut se retrouver en tête d'un classement de la dangerosité avec quatre cambriolages dans l'année. Une commune de 200 000 habitants n'y arrivera jamais. Cette mécanique, identifiée dès 1971 par Daniel Kahneman et Amos Tversky, structure une bonne partie des palmarès qui font la une des journaux. Cette série en démonte dix.

## Les épisodes

| N° | Sujet | Statut |
|----|-------|--------|
| 01 | Cambriolages | publié |
| 02 | Lycées | à venir |
| 03 | Élections, bureau par bureau | à venir |
| 04 | Tribunaux laxistes | à venir |
| 05 | Maternités et mortalité néonatale | à venir |
| 06 | EHPAD | à venir |
| 07 | Notations Google des médecins | à venir |
| 08 | Saisies de drogue par poste de douane | à venir |
| 09 | Centres de PMA | à venir |
| 10 | Comment lire un chiffre | à venir |

## Organisation du dépôt

```
.
├── README.md                      ← ce fichier
├── data/                          ← données brutes (gitignorées si > 100 Mo)
│   ├── delinquance/               ← base SSMSI 2025 (593 Mo, non poussée)
│   ├── lycees/                    ← résultats Bac par académie
│   ├── sante/                     ← inventaire data.gouv santé
│   └── referentiels/              ← COG INSEE (téléchargé auto par le code)
├── episodes/                      ← un dossier par épisode
│   └── 01_cambriolages/
│       ├── episode_01.qmd         ← le rapport reproductible
│       ├── redactions.md          ← brouillons de texte (privé, gitignoré)
│       ├── empreinte_vs_nuage.svg ← schéma explicatif
│       └── (régénéré au rendu)    HTML, graphique interactif, CSV exports
├── scripts/                       ← scripts d'exploration ad-hoc
└── notion/                        ← structure de l'espace Notion (privé)
```

## Méthode

Chaque épisode part d'une source publique et passe par les mêmes étapes : extraction des données via DuckDB en R, visualisation taux contre taille en échelle logarithmique, comparaison entre un classement « brut » (méthode médiatique habituelle) et un classement corrigé (avec un seuil de population minimal, ou un lissage bayésien). Tous les fichiers `.qmd` sont reproductibles : il suffit d'ouvrir Quarto dans RStudio et de cliquer sur Render.

Pour relancer l'analyse de l'épisode 1, ouvrir `episodes/01_cambriolages/episode_01.qmd` dans RStudio. Le script télécharge automatiquement le Code Officiel Géographique INSEE 2025 si nécessaire. La base communale de la délinquance, trop volumineuse pour GitHub, est à télécharger séparément depuis [data.gouv.fr](https://www.data.gouv.fr/datasets/bases-statistiques-communale-departementale-et-regionale-de-la-delinquance-enregistree-par-la-police-et-la-gendarmerie-nationales/) et à placer dans `data/delinquance/`.

Packages R : `duckdb`, `DBI`, `dplyr`, `ggplot2`, `scales`, `plotly`, `htmlwidgets`.

## Sources

Les sources varient selon les épisodes — SSMSI, DREES, ATIH, ministère de la Justice, INSEE, Agence de la biomédecine, scraping ciblé pour les épisodes consumeristes. Chaque article publié comporte sa note méthodologique avec lien direct vers la source.

## Contact

Sacha Zaouati — datajournaliste indépendant. Pige presse, études B2B, conférences. sacha.zaouati@gmail.com.

## Licence

Code : MIT. Articles et graphiques : CC BY 4.0 — citation demandée.
