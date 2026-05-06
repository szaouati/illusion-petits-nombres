---
name: nouvel-episode
description: |
  À utiliser lorsque Sacha souhaite démarrer un nouvel épisode de la série
  "L'illusion des petits nombres" (un dossier `episodes/XX_thème/` avec
  son `.qmd` reproductible, son `redactions.md` privé, sa structure
  scrollytelling optionnelle, et la mise à jour du README + CLAUDE.md).
  Déclencheurs : "lance l'épisode 02", "crée le squelette de l'épisode XX",
  "génère un nouvel épisode sur les EHPAD", "démarrer l'épisode lycées".
  Ne pas utiliser pour modifier un épisode existant ni pour rédiger
  l'article lui-même : ce skill ne fait que poser le squelette.
---

# Skill : nouvel-episode

## But

Générer en une commande la structure complète d'un nouvel épisode, calquée
sur l'épisode 01 (cambriolages) qui sert de référence canonique. Le skill
ne rédige **pas** l'article : il pose les fichiers et les chemins, fait
les mises à jour transverses (README, CLAUDE.md) et liste à Sacha les
informations qui lui manquent encore (URL de la source data.gouv, etc.).

## Avant de commencer (à demander à Sacha si non précisé)

1. **Numéro de l'épisode** (deux chiffres avec zéro initial : `02`, `03`, …, `10`).
2. **Slug court** pour le nom du dossier (un mot, en minuscules, sans accent :
   `lycees`, `tribunaux`, `maternites`, `ehpad`, `medecins`, `douanes`, `pma`,
   `synthese`).
3. **Titre éditorial** complet pour le `.qmd` et le README (ex : « Les lycées
   à 100 % de réussite au bac : une géographie des petits effectifs »).
4. **Statistique-cible** en une phrase (ex : « taux de réussite au bac par
   établissement »).
5. **Source officielle** (URL data.gouv.fr ou DREES ou ATIH). Si non connue,
   le marquer `[À TROUVER]` et l'ajouter aux chantiers.
6. **Unité de l'échantillon** : commune ? établissement ? bureau de vote ?
   poste de douane ? — c'est ce qui détermine la variable `n` dans la
   simulation Poisson.

## Étapes du skill

### Étape 1 — Vérifier que le numéro n'existe pas déjà

```bash
ls episodes/ | grep "^${NUMERO}_"
```

Si un dossier existe déjà avec ce numéro, **stopper** et demander à Sacha.

### Étape 2 — Créer la structure de dossiers

```
episodes/${NUMERO}_${SLUG}/
├── episode_${NUMERO}.qmd        ← rapport reproductible (template ci-dessous)
├── redactions.md                ← brouillons (gitignoré, à créer même vide)
└── scrollytelling/              ← optionnel, à créer plus tard si besoin
    ├── index.html
    ├── R/
    └── svg/
```

Les sous-dossiers `episode_${NUMERO}_files/`, les CSV exports, et le HTML
généré au rendu Quarto sont déjà gitignorés via `.gitignore` racine.

### Étape 3 — Générer `episode_${NUMERO}.qmd`

Utiliser ce template, en remplaçant les variables `${...}`. Le squelette
reprend les six chunks-types de l'épisode 01 et laisse les sections
éditoriales en `[À RÉDIGER]` pointant vers `redactions.md`.

````markdown
---
title: "Épisode ${NUMERO} — ${TITRE}"
subtitle: "L'illusion des petits nombres, série en 10 actes"
author: "Sacha Zaouati"
date: today
format:
  html:
    toc: true
    code-fold: true
    theme: cosmo
execute:
  warning: false
  message: false
---

## Le constat

[À RÉDIGER : voir `redactions.md` — section §1.]

## La méthode

```{r setup}
library(duckdb)
library(DBI)
library(dplyr)
library(ggplot2)
library(scales)
library(plotly)
library(htmlwidgets)

con <- dbConnect(duckdb::duckdb(), dbdir = ":memory:")

# Chemin relatif depuis episodes/${NUMERO}_${SLUG}/ vers data/
csv_path <- "../../data/${SLUG}/[NOM_DU_FICHIER_SOURCE].csv"

dbExecute(con, sprintf("
  CREATE VIEW source AS
  SELECT * FROM read_csv_auto('%s', delim=';', header=true)
", csv_path))
```

```{r data}
# Extraction de la statistique-cible : ${STATISTIQUE_CIBLE}
# Unité de l'échantillon : ${UNITE} (= variable n pour la simulation Poisson)

donnees <- dbGetQuery(con, "
  SELECT
    -- À adapter à la structure de la source
    ...
  FROM source
  WHERE ...
")

cat("Échantillons analysés :", nrow(donnees), "\n")
```

## Le graphique — empreinte digitale des petits nombres

```{r graphique}
#| fig-width: 10
#| fig-height: 6
#| fig-cap: "Taux observé selon la taille de l'échantillon. Chaque point = un(e) ${UNITE}."

ggplot(donnees, aes(x = n, y = taux)) +
  geom_point(alpha = 0.15, size = 0.5, color = "#4A9EBD") +
  scale_x_log10() +
  labs(
    title = "L'empreinte digitale des petits nombres",
    subtitle = "${TITRE_COURT} — la dispersion explose à gauche",
    x = "Taille de l'échantillon (échelle logarithmique)",
    y = "Taux observé",
    caption = "Source : ${SOURCE_OFFICIELLE} • Analyse : Sacha Zaouati"
  ) +
  theme_minimal(base_size = 12)
```

## Le palmarès brut

```{r palmares-brut}
top10_brut <- donnees |>
  arrange(desc(taux)) |>
  head(10)

knitr::kable(top10_brut, digits = 1,
             caption = "Top 10 brut — méthode médiatique habituelle.")
```

[À RÉDIGER : voir `redactions.md` — section §2. Commenter qui apparaît dans
ce palmarès et quelle est la taille typique des échantillons.]

## La correction statistique

```{r palmares-corrige}
# Choix méthodologique : seuil de fiabilité statistique
# (à justifier dans la section éditoriale ci-dessous)
SEUIL_N <- ${SEUIL_PROVISOIRE}

top10_corrige <- donnees |>
  filter(n >= SEUIL_N) |>
  arrange(desc(taux)) |>
  head(10)

knitr::kable(top10_corrige, digits = 1,
             caption = sprintf("Top 10 corrigé (n ≥ %d).", SEUIL_N))
```

[À RÉDIGER : voir `redactions.md` — section §3. Justifier le seuil par
analogie avec un seuil de fiabilité reconnu dans le secteur (ex : 300
accouchements/an pour les maternités). Présenter aussi en complément
le palmarès Empirical Bayes (`ebbr`) si la donnée s'y prête.]

## Ce que ça raconte de plus large

[À RÉDIGER : voir `redactions.md` — section §4. Mettre en perspective avec
le traitement médiatique habituel et le mécanisme de la régression vers la
moyenne. Anticiper l'épisode suivant.]

## Note méthodologique

[À RÉDIGER : voir `redactions.md` — section §5. Source, périmètre,
hypothèses statistiques (loi de Poisson, indépendance, taux de référence),
graine de simulation, reproductibilité (URL GitHub), licence.]

```{r exports, include=FALSE}
write.csv(donnees,      "${SLUG}_${ANNEE}.csv", row.names = FALSE)
write.csv(top10_brut,    "top10_brut.csv",       row.names = FALSE)
write.csv(top10_corrige, "top10_corrige.csv",    row.names = FALSE)
```

```{r cleanup, include=FALSE}
dbDisconnect(con, shutdown = TRUE)
```
````

### Étape 4 — Créer `redactions.md` (gitignoré)

Fichier vide avec ce squelette de cinq sections :

```markdown
# Brouillons rédactionnels — Épisode ${NUMERO} (${SLUG})

> Fichier privé (gitignoré). Sources, citations, formulations alternatives,
> notes de relecture. Ce qui finit dans le `.qmd` est une version éditée.

## §1 — Le constat (accroche)

[Variantes ici. Une accroche par chiffre choc + comparaison externe, comme
Vieille-Toulouse 67,9 ‰ → 95 000 cambriolages à Paris. Trouver le pendant
pour ${UNITE}.]

## §2 — Le palmarès brut

[Ce que dit le palmarès brut, qui apparaît, taille typique de l'échantillon.]

## §3 — La correction statistique

[Justification du seuil. Référence au seuil sanitaire 300 accouchements ou
50 chirurgies cardiaques. Présenter aussi le palmarès EB si pertinent.]

## §4 — Mise en perspective

[Comment la presse traite habituellement ce palmarès. Régression vers la
moyenne (mécanisme et prédiction testable). Pont vers l'épisode suivant.]

## §5 — Note méthodologique

[Source officielle (URL exacte), périmètre, hypothèses statistiques,
graine, lien GitHub, licence MIT/CC BY 4.0.]

# Sources à citer

- [Liste des références académiques mobilisées : Tversky & Kahneman 1971,
  Spiegelhalter 2005 si funnel plot, Robbins 1956 si EB, Besley & Case
  1995 si on remet l'encart "défense des palmarès", etc.]
```

### Étape 5 — Mettre à jour le `README.md`

Dans le tableau des épisodes, passer la ligne `${NUMERO}` du statut
« à venir » au statut « en cours ».

### Étape 6 — Mettre à jour le `CLAUDE.md`

Section 10 (« Chantiers en cours »), ajouter sous le bloc « Épisodes
suivants » un sous-bloc dédié à l'épisode ${NUMERO} avec les jalons :
pipeline, scrollytelling, article, funnel plot Spiegelhalter, EB.

### Étape 7 — Restitution à Sacha

Lui afficher en réponse :
- Le chemin du dossier créé.
- Les variables qui restent à compléter dans le `.qmd` (chemins de données,
  noms de colonnes SQL, seuil provisoire).
- La liste des sources/données encore à trouver si la source officielle
  était `[À TROUVER]`.
- La commande pour ouvrir le `.qmd` dans RStudio.

**Ne pas commiter automatiquement.** Sacha vérifie d'abord, commit ensuite
manuellement avec un message du type `episode-${NUMERO}: pose le squelette`.

## Garde-fous

- Ne jamais **dupliquer** la base SSMSI ou tout CSV > 100 Mo dans le
  nouveau dossier d'épisode. Pointer vers `data/${SLUG}/` ou
  `data/delinquance/` via chemin relatif.
- Ne jamais inscrire de chemin absolu `/Users/sacha/...`.
- Ne jamais committer `redactions.md` — il est couvert par `.gitignore`,
  vérifier que la règle `episodes/*/redactions.md` y est bien.
- Ne jamais inventer une URL data.gouv.fr — si Sacha ne la fournit pas,
  laisser `[À TROUVER]`.
