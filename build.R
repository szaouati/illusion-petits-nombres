# =============================================================================
# build.R — construction du dossier docs/ servi par GitHub Pages
# =============================================================================
#
# Pourquoi ce script existe :
# ---------------------------
# La source canonique de chaque épisode vit dans `episodes/XX_thème/`. Mais
# GitHub Pages ne peut servir qu'un seul dossier-racine de publication par
# dépôt. On a choisi `docs/` (configurable dans Settings > Pages sur GitHub).
# Ce script copie les pages publiables (scrollytelling autonome, graphiques
# Plotly autonomes, PDF article) depuis `episodes/` vers `docs/`, en respectant
# une arborescence URL stable :
#
#   docs/
#   ├── .nojekyll                ← désactive Jekyll (sinon les `_files/` Quarto
#   │                              ne sont pas servis)
#   ├── index.html               ← page d'accueil de la série
#   └── episode-01/
#       ├── index.html           ← le scrollytelling
#       ├── R/                   (sources des SVG, simple curiosité publique)
#       └── svg/                 (les 10 SVG inlinés dans index.html)
#
# Comment l'utiliser :
# --------------------
# Depuis la racine du dépôt, dans RStudio (Tools > Terminal) ou Terminal :
#   Rscript build.R
# Puis : git add docs/ && git commit -m "docs: regénère les pages publiables"
# Puis : git push.
#
# GitHub Pages mettra environ une à dix minutes à publier la mise à jour.
#
# Ajouter un nouvel épisode :
# ---------------------------
# Ajouter une entrée à la liste `publications` ci-dessous, puis relancer
# le script.
# =============================================================================

# --- Configuration : ce qu'on publie ---

publications <- list(
  list(
    src = "episodes/01_cambriolages/scrollytelling",
    dst = "docs/episode-01",
    label = "Épisode 01 — Cambriolages (scrollytelling)"
  )
  # Au fur et à mesure :
  # list(src = "episodes/02_lycees/scrollytelling",
  #      dst = "docs/episode-02",
  #      label = "Épisode 02 — Lycées (scrollytelling)"),
  # list(src = "episodes/03_elections/scrollytelling",
  #      dst = "docs/episode-03",
  #      label = "Épisode 03 — Élections (scrollytelling)"),
)

# --- 1. Garantir l'existence de docs/ et de .nojekyll ---

if (!dir.exists("docs")) {
  dir.create("docs", recursive = TRUE)
  message("Créé : docs/")
}
nojekyll <- "docs/.nojekyll"
if (!file.exists(nojekyll)) {
  file.create(nojekyll)
  message("Créé : ", nojekyll, " (désactive Jekyll)")
}

# --- 2. Fonction de copie récursive avec nettoyage de la cible ---

copier_dossier <- function(src, dst, label = NULL) {
  if (!dir.exists(src)) {
    warning("Source inexistante : ", src, " — épisode probablement pas encore prêt.")
    return(invisible(FALSE))
  }
  # On vide d'abord la destination pour éviter les fichiers orphelins d'une
  # version précédente (par exemple un SVG renommé).
  if (dir.exists(dst)) unlink(dst, recursive = TRUE, force = TRUE)
  dir.create(dst, recursive = TRUE, showWarnings = FALSE)

  # Filtres : on n'embarque pas dans la version publique les fichiers
  # de session R (souvent gros, et susceptibles de fuiter du code privé)
  # ni les fichiers système macOS.
  exclus_pattern <- "(^|/)(\\.RData|\\.Rhistory|\\.DS_Store|\\.Rproj\\.user|.*\\.Rproj)$"

  fichiers <- list.files(src, recursive = TRUE, full.names = FALSE,
                         all.files = TRUE, no.. = TRUE)
  fichiers <- fichiers[!grepl(exclus_pattern, fichiers)]

  for (f in fichiers) {
    src_f <- file.path(src, f)
    dst_f <- file.path(dst, f)
    dir.create(dirname(dst_f), recursive = TRUE, showWarnings = FALSE)
    file.copy(src_f, dst_f, overwrite = TRUE)
  }
  message(sprintf(
    "✓ %s : %d fichier(s) copié(s) vers %s",
    label %||% basename(src), length(fichiers), dst
  ))
  invisible(TRUE)
}

# Petit utilitaire (équivalent de l'opérateur `%||%` introduit dans R 4.4)
`%||%` <- function(a, b) if (!is.null(a)) a else b

# --- 3. Exécution ---

message("== Build de docs/ pour GitHub Pages ==")
for (pub in publications) {
  copier_dossier(pub$src, pub$dst, pub$label)
}

message("\nBuild terminé. Étapes suivantes :")
message("  git add docs/")
message("  git commit -m \"docs: regénère les pages publiables\"")
message("  git push")
