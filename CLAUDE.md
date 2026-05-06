# CLAUDE.md — Briefing du projet

> Ce fichier est lu automatiquement par Claude Code à chaque démarrage de session
> dans ce dossier. Il sert aussi de référence pour les sessions Cowork et claude.ai.
> Tenir à jour : il est la source de vérité pour toute collaboration avec Claude.

---

## 1. Le projet

**Titre** : *L'illusion des petits nombres*
**Auteur** : Sacha Zaouati — datajournaliste indépendant
**Format** : série de 10 enquêtes datajournalistiques publiées sur Substack
**Période de publication** : du 2 au 11 mai 2026 (un épisode tous les un à deux jours)
**Dépôt public** : ce repo Git, sous licence MIT (code) + CC BY 4.0 (articles et graphiques)

**Pitch en deux phrases**
La presse française publie en permanence des classements de communes, lycées, hôpitaux, tribunaux ou médecins, en ignorant systématiquement la *loi des petits nombres* identifiée par Kahneman et Tversky en 1971. Cette série démonte dix de ces palmarès pour montrer que le hasard parle plus fort que la sociologie quand on calcule un taux sur un petit échantillon — et propose, pour chaque cas, un classement statistiquement honnête.

**Liste des épisodes** (à jour dans `README.md`) :
1. Cambriolages — *publié*
2. Lycées
3. Élections, bureau par bureau
4. Tribunaux laxistes
5. Maternités et mortalité néonatale
6. EHPAD
7. Notations Google des médecins
8. Saisies de drogue par poste de douane
9. Centres de PMA
10. Comment lire un chiffre (épisode-synthèse)

**Objectifs adjacents** (ne pas oublier en travaillant) :
- Servir de portfolio pour une activité de pige presse + études B2B (cf. `notion/structure.md`).
- Constituer la base d'une future startup de datavisualisation, à terme avec scrollytelling type NYT/Pudding.
- Documenter publiquement la méthode pour la communauté datajournalisme francophone.

---

## 2. Stack technique

| Couche | Outil |
|---|---|
| Langage d'analyse | R (≥ 4.3) |
| Lecture de gros CSV | DuckDB en mémoire (`duckdb`, `DBI`) |
| Manipulation | `dplyr`, pipe natif `|>` |
| Graphiques statiques | `ggplot2` + `scales` |
| Graphiques interactifs | `plotly` + `htmlwidgets` (export HTML autonome) |
| Statistique avancée | `ebbr` (Empirical Bayes shrinkage) pour les classements corrigés |
| Reproductibilité | Quarto (`.qmd`) — Render dans RStudio |
| Reproductibilité packages | `renv` *(à initialiser, voir §10)* |
| Hébergement graphiques | GitHub Pages (pour iframes Substack) |
| Diffusion finale | Substack (article + iframe Datawrapper / GitHub Pages) |
| Versioning | Git + GitHub |
| Pilotage éditorial / commercial | Notion (privé, gitignoré) |

**Environnement de Sacha** : MacBook Pro M5 Pro, 24 Go RAM. RStudio + Claude Code (terminal) + Office 365 + Notion. Niveau code : terminale spé maths, deux stages presse (L'Agefi, AEF info). Donc : **expliquer les choix techniques**, ne pas supposer une maîtrise avancée de R, JS ou Git.

---

## 3. Structure du dépôt

```
.
├── CLAUDE.md                       ← ce fichier
├── README.md                       ← présentation publique
├── .gitignore
├── build.R                         ← script de build de docs/ (Pages)
├── data/
│   ├── delinquance/                ← base SSMSI (593 Mo, gitignorée)
│   ├── lycees/                     ← résultats Bac par académie
│   ├── sante/                      ← inventaire data.gouv santé
│   └── referentiels/               ← COG INSEE (téléchargé auto, gitignoré)
├── episodes/                       ← SOURCES CANONIQUES par épisode
│   └── 01_cambriolages/
│       ├── episode_01.qmd          ← rapport reproductible (HTML + PDF)
│       ├── redactions.md           ← brouillons (PRIVÉ, gitignoré)
│       ├── empreinte_vs_nuage.svg  ← schéma explicatif
│       ├── scrollytelling/         ← page autonome (HTML + 10 SVG + scripts R)
│       └── (régénérés au rendu)    HTML, PDF, graphique interactif, CSV
├── scripts/                        ← scripts d'exploration ad-hoc
├── notion/                         ← structure Notion (PRIVÉ, gitignoré)
├── docs/                           ← VERSION PUBLIQUE servie par GitHub Pages
│   ├── .nojekyll                   ← désactive Jekyll (sinon les `_files/` Quarto ne sont pas servis)
│   ├── index.html                  ← page d'accueil de la série
│   └── episode-01/                 ← copie du scrollytelling, peuplé par build.R
│       ├── index.html
│       ├── R/
│       └── svg/
└── The-Data-Journalism-Handbook-1.pdf, -2.pdf  ← références (gitignorées, copyright)
```

**Règle d'or** : `episodes/` contient les sources, `docs/` contient ce qui est servi en public. On ne modifie JAMAIS `docs/` à la main — `docs/` est régénéré par `Rscript build.R` à la racine du dépôt. `docs/.nojekyll` doit toujours exister (sinon GitHub Pages applique Jekyll qui ignore certains fichiers commençant par `_`).

---

## 4. Méthodologie standardisée (à suivre pour chaque épisode)

Reprend le squelette de `notion/structure.md` :

1. **Identifier la statistique-cible** (ex : taux de cambriolages par commune).
2. **Localiser la source officielle** (data.gouv.fr / DREES / ATIH / scraping).
3. **Charger en R via DuckDB** dans `scripts/exploration_*.R`.
4. **Tracer le nuage taux × taille en échelle log** — c'est l'« empreinte digitale » des petits nombres.
5. **Extraire le palmarès brut** (top 10 par taux, méthode médiatique habituelle).
6. **Construire le palmarès corrigé** :
   - version *seuil* (ex : population ≥ 10 000) — facile à expliquer ;
   - version *Empirical Bayes* (`ebbr`) — robuste, à présenter en complément.
7. **Compiler en Quarto** (`episode_XX_*.qmd`) avec `code-fold: true`.
8. **Rendre HTML** + publier sur GitHub Pages.
9. **Exporter les CSV** pour Datawrapper et créer le graphique interactif.
10. **Rédiger l'article Substack** (iframe Datawrapper + lien GitHub).
11. **Pousser sur GitHub** avec un message de commit clair.
12. **Promotion** LinkedIn + Twitter/X (extraits + lien).

---

## 5. Ton éditorial

- **Sobriété façon *Le Monde Pixels* / *Alternatives Économiques*** : pas de superlatifs, pas de putaclic.
- **Pédagogique sans condescendance** : le lecteur visé est un cadre curieux non-statisticien.
- **Toute affirmation chiffrée est sourcée** dans la légende du graphique ou la note méthodologique.
- **Pas d'opinion politique implicite** : la série critique la méthode statistique de la presse, pas les rédactions individuelles. Quand un classement publié dans la presse est cité, le citer factuellement, sans mépris.
- **Le mot « danger » est piégé** : préférer « cambriolages », « infractions enregistrées ». Idem pour « laxiste », « performant », « bon élève » — toujours mettre des guillemets quand on reprend le langage médiatique.
- **Éviter les anglicismes** : « seuil de population minimal », pas « threshold » ; « lissage bayésien », pas « shrinkage » dans le corps de l'article (mais OK en note méthodo).
- **Phrases courtes**, paragraphes de 3 à 5 lignes. Pas de listes à puces dans les articles Substack (le format mange les puces).

---

## 6. Conventions de code R

- **Commentaires en français**, mais noms de variables et de fonctions en anglais ou en français court (`cambri`, `top10_brut`).
- **Pipe natif `|>`**, pas `%>%`.
- **`library()` regroupés en haut du chunk `setup`** d'un `.qmd`, jamais dispersés dans les chunks suivants.
- **Chemins relatifs** depuis le `.qmd`, jamais de chemin absolu (corriger immédiatement si on en voit un — voir bug à la ligne 18 de `scripts/exploration_delinquance.R`).
- **Fermer les connexions DuckDB** : tout `dbConnect()` est apparié à un `dbDisconnect(con, shutdown = TRUE)` dans un dernier chunk `cleanup`.
- **Conversions explicites** : la base SSMSI utilise les virgules décimales (`taux_pour_mille = "5,3"`) — toujours `REPLACE(..., ',', '.')` puis `CAST AS DOUBLE` côté SQL, ou `as.numeric(gsub(...))` côté R.
- **Palette projet** (à factoriser dans `theme_petits_nombres.R` quand on l'aura créée) :
  - Petites communes (effet maximal) : `#FF6B6B` (rouge)
  - Strate 300–1k : `#FFB347` (orange)
  - Strate 1k–10k : `#4A9EBD` (bleu moyen)
  - Strate 10k–100k : `#5DADE2` (bleu clair)
  - Grandes (loi des grands nombres) : `#1F4E79` (bleu nuit)
- **Typographie** : Inter, fallback Helvetica.

---

## 7. Sécurité et confidentialité — à NE JAMAIS faire

- **Ne jamais committer** :
  - les données brutes volumineuses (`data/delinquance/*.csv`, > 100 Mo, refusées par GitHub) ;
  - les référentiels téléchargés auto (`data/referentiels/`) ;
  - les brouillons rédactionnels (`episodes/*/redactions.md`) — ils peuvent contenir des passages que je ne veux pas rendre publics ;
  - le dossier `notion/` — il contient les pricings commerciaux et templates emails ;
  - tout fichier en `_OLD_*` (purges en attente).
- **Ne jamais inventer un chiffre** : si une donnée manque, le dire explicitement dans le texte ou écrire `[À VÉRIFIER]`.
- **Ne jamais publier sans relecture humaine** : tout texte généré par Claude doit être relu et signé par Sacha.
- **Ne jamais utiliser de chemin absolu commençant par `/Users/sacha/...`** dans le code versionné.
- **Ne jamais pousser sur `main` sans message de commit explicite** (cf. §9).

---

## 8. Comment travailler avec Claude sur ce projet

**Répartition des produits Claude** :
- **Claude Code (terminal)** — outil principal. Édition de `.qmd`, debug R, refacto, commits Git, génération d'épisodes via skill custom. Lance `claude` depuis la racine du dépôt.
- **Cowork (app desktop)** — orchestration multi-fichiers, aperçu HTML, accès Notion via MCP, livrables bureautiques (docx pour pitches presse, pptx pour conférences).
- **Claude.ai Projects** — un seul Project nommé « Illusion des petits nombres » pour la rédaction longue. Knowledge à charger : `README.md`, `CLAUDE.md`, `notion/structure.md`, les deux *Data Journalism Handbooks*, et les `.qmd` au fur et à mesure. Une conversation persistante par épisode pour la rédaction.

**Modèles** :
- **Sonnet 4.6** par défaut (code R, édition, dataviz courantes).
- **Opus 4.6** pour la statistique pointue (choix d'un seuil, interprétation bayésienne, robustesse), l'architecture (refactos transverses), et les sessions de revue éditoriale critiques.
- **Haiku 4.5** uniquement via API quand on automatisera des tâches batch (classifications, génération massive de variantes de titres).

**Quand tu démarres une session** (Claude lui-même, pas Sacha) :
1. Lire ce `CLAUDE.md`.
2. Lire le `README.md` (état d'avancement public de la série).
3. Si tu travailles sur un épisode précis, lire `episodes/XX_*/episode_XX.qmd` *avant* de proposer quoi que ce soit.
4. Vérifier quel est l'épisode en cours via le tableau du README (statut `À venir` / `En cours` / `Publié`).
5. Demander confirmation avant tout commit Git ou tout `quarto render` qui réécrit des fichiers.

**Style de réponse attendu** :
- Concis, en français, sans formatage excessif (pas de bullet points pour des phrases courtes).
- Toujours expliquer le *pourquoi* d'un choix technique, pas juste le *comment* — Sacha apprend en faisant.
- En cas de doute statistique, citer une source (handbook, article académique, doc R officielle).
- Ne jamais générer de code sans expliquer brièvement ce qu'il fait au-dessus.

**Style de rédaction d'article (consigne explicite de Sacha)** :
Pour toute rédaction de paragraphe, section, encart, légende ou note méthodologique destinée à un article, viser un texte **précis, neutre, technique et pas trop bref**. Sacha relit et réécrit systématiquement avant publication, donc il préfère recevoir une matière dense, sourcée, légèrement trop longue plutôt qu'une version déjà éditorialisée et trop courte. Concrètement :
- Donner les chiffres exacts, pas des arrondis vagues.
- Citer les auteurs et années entre parenthèses (Spiegelhalter 2005, Robbins 1956, Besley & Case 1995).
- Expliciter les hypothèses statistiques (loi de Poisson, indépendance, taux moyen de référence).
- Ne pas couper court sous prétexte que le lecteur "comprendra" — formuler le mécanisme sous-jacent.
- Pas d'effets de style superflus : pas de questions rhétoriques, pas de "et c'est là que tout bascule", pas d'exclamations.
- Phrases courtes mais paragraphes développés (4-6 lignes typiques).

---

## 9. Conventions Git

- **Branche par défaut** : `main` (pas de `master`).
- **Format des messages de commit** :
  - `episode-XX: <action>` pour les changements liés à un épisode (ex : `episode-01: rédige la note méthodologique`).
  - `chore: <action>` pour la maintenance (ex : `chore: ajoute renv lockfile`).
  - `data: <action>` pour les ajouts de jeux de données.
  - `docs: <action>` pour le README, CLAUDE.md, CONTRIBUTING.md.
- **Toujours en français**, à l'impératif (« ajoute », « corrige », « refactorise »).
- **Ne jamais utiliser `git push --force`** sur `main`.
- **Avant tout commit, vérifier `git status`** et confirmer avec Sacha si des fichiers gitignorés (notion/, redactions.md) apparaissent par erreur.

---

## 10. Chantiers en cours (à mettre à jour)

**Épisode 01 — cambriolages**
- [x] Pipeline R/Quarto + graphiques statiques + plotly interactif
- [x] Page scrollytelling autonome (`episodes/01_cambriolages/scrollytelling/index.html` + 10 SVG + 3 scripts R)
- [x] Contenu rédigé du PDF intégré dans `episode_01.qmd` (le `.qmd` redevient la source canonique ; le PDF de design est conservé en archive)
- [x] YAML du `.qmd` en multi-format (HTML + PDF via `quarto render`)
- [x] Funnel plot Spiegelhalter posé en local (`funnel_plot_spiegelhalter.png/svg`)
- [ ] Intégrer dans l'article les deux corrections statistiques pointées dans `Relecture 1.md` (hypothèse de communes identiques + mécanisme de la régression vers la moyenne)
- [ ] Intégrer l'encart « défense des palmarès » (yardstick competition Besley & Case 1995, Burgess et al. au Pays de Galles) — déjà drafté dans `Relecture 1.md`
- [ ] Insérer dans le `.qmd` le funnel plot Spiegelhalter (chunk + commentaire)
- [ ] Ajouter un palmarès *Empirical Bayes* (`ebbr`) en complément du seuil ≥ 10 000, à présenter en note méthodologique
- [ ] Audit accessibilité du graphique principal (alt text, simulation daltonisme avec `colorblindr`)
- [ ] Trancher : `scrollytelling/` (canonique) vs `scrollytelling-v2-interactif/` (test à améliorer plus tard) — la décision actuelle est : `scrollytelling/` est canonique
- [x] **Bug structure** : déplacer le CSV SSMSI 593 Mo de `episodes/01_cambriolages/` vers `data/delinquance/` et corriger le chemin dans `episode_01.qmd`

**Infrastructure projet**
- [x] `CLAUDE.md` à la racine
- [x] Skill custom `.claude/skills/nouvel-episode/SKILL.md`
- [x] Dossier `docs/` à la racine + `.nojekyll` + page d'accueil
- [x] Script `build.R` à la racine pour peupler `docs/episode-XX/` depuis `episodes/XX_thème/scrollytelling/`
- [x] Activer GitHub Pages côté serveur : Settings > Pages > Source: `main` branch + dossier `/docs`. Attendre 1-10 min, vérifier l'URL `https://sachazaouati.github.io/illusion-petits-nombres/`
- [ ] Initialiser `renv` à la racine
- [ ] Créer `theme_petits_nombres.R` à la racine (palette + thème ggplot factorisés)

**Épisodes suivants**
- [ ] Lancer la rédaction de l'épisode 02 (Lycées) — données dans `data/lycees/fr-en-baccalaureat-par-academie.csv`

---

## 11. Sources de référence à consulter

- *The Data Journalism Handbook* 1 et 2 (PDF à la racine).
- Kahneman & Tversky, « Belief in the Law of Small Numbers », *Psychological Bulletin*, 1971.
- Robinson, *Introduction to Empirical Bayes*, gratuit en ligne — pour comprendre `ebbr`.
- Chamandy *et al.*, Google's *Estimating uncertainty for massive data streams* — pour les seuils.
- The Pudding (`pudding.cool`) et NYT Upshot — pour les références dataviz.

---

*Dernière mise à jour : 2026-05-06 — par Claude (session de cadrage initial)*
*À mettre à jour à chaque évolution majeure de la méthode, du stack ou de la structure.*
