# =============================================================================
# Exploration de la base délinquance communale (5,2M lignes, 593 Mo)
# Méthode : DuckDB en R (lit directement le CSV, pas besoin de tout charger)
# =============================================================================

# 1. Installation (une seule fois)
# install.packages(c("duckdb", "DBI", "dplyr", "ggplot2", "ebbr"))

library(duckdb)
library(DBI)
library(dplyr)
library(ggplot2)

# 2. Connexion à une base DuckDB en mémoire
con <- dbConnect(duckdb::duckdb(), dbdir = ":memory:")

# 3. Chemin vers le CSV (à adapter)
csv_path <- "/Users/sacha/Library/CloudStorage/GoogleDrive-sacha.zaouati@gmail.com/Mon Drive/projets journalisme/petits_nombres/palmares_delinquence/donnee-data.gouv-2025-geographie2025-produit-le2026-02-03.csv"

# 4. Création d'une vue sur le CSV (rien n'est chargé en RAM)
dbExecute(con, sprintf("
  CREATE VIEW delinquance AS
  SELECT * FROM read_csv_auto('%s', delim=';', decimal_separator=',', header=true)
", csv_path))

# 5. Aperçu de la structure
dbGetQuery(con, "SELECT * FROM delinquance LIMIT 10")
dbGetQuery(con, "SELECT DISTINCT indicateur FROM delinquance")
dbGetQuery(con, "SELECT DISTINCT annee FROM delinquance ORDER BY annee")

# =============================================================================
# Exemple : taux de cambriolages 2024 vs taille de commune (TON GRAPHIQUE)
# =============================================================================

cambri <- dbGetQuery(con, "
  SELECT
    CODGEO_2025,
    insee_pop,
    nombre,
    taux_pour_mille
  FROM delinquance
  WHERE indicateur = 'Cambriolages de logement'
    AND annee = '2024'
    AND est_diffuse = 'diff'
    AND insee_pop > 0
")

# Conversion des virgules en points (FR -> num)
cambri <- cambri |>
  mutate(
    taux_pour_mille = as.numeric(gsub(",", ".", taux_pour_mille)),
    insee_pop = as.numeric(insee_pop),
    nombre = as.numeric(nombre)
  )

# Le graphique « empreinte digitale » des petites communes
ggplot(cambri, aes(x = insee_pop, y = taux_pour_mille)) +
  geom_point(alpha = 0.15, size = 0.5, color = "#4A9EBD") +
  scale_x_log10(
    breaks = c(100, 300, 1000, 10000, 100000),
    labels = c("100", "300", "1k", "10k", "100k")
  ) +
  scale_y_continuous(limits = c(0, 50)) +
  geom_vline(xintercept = c(100, 300, 1000, 10000),
             linetype = "dotted", color = "white", alpha = 0.5) +
  labs(
    title = "Cambriolages 2024 : les petites communes dominent les extrêmes",
    subtitle = "Chaque point = une commune",
    x = "Population (échelle log)",
    y = "Cambriolages pour 1 000 habitants",
    caption = "Source : SSMSI, data.gouv.fr"
  ) +
  theme_minimal()

# =============================================================================
# BONUS : trouver les VRAIS outliers via Empirical Bayes shrinkage
# (l'angle « signal sous le bruit »)
# =============================================================================
# library(ebbr)
# fit <- cambri |>
#   mutate(success = nombre, total = insee_pop) |>
#   ebb_fit_prior(success, total) |>
#   add_ebb_estimate(success, total)
# # Les communes vraiment dangereuses après lissage bayésien :
# fit |> arrange(desc(.fitted)) |> head(20)

# 6. Toujours fermer la connexion
dbDisconnect(con, shutdown = TRUE)

# =============================================================================
# Pour publier la méthode : transforme ce script en .qmd (Quarto)
# Tu obtiens un rapport reproductible HTML/PDF avec code + graphiques.
# Quarto est intégré à RStudio (File > New File > Quarto Document).
# =============================================================================
