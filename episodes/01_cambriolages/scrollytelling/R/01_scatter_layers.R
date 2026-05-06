# ====================================================================
# Génère les 6 SVG progressifs du nuage de points (scatter)
# pour la page scrollytelling de l'épisode 1.
#
# Sortie : ../svg/0[1-6]_scatter_*.svg
# Dépend de : top10_brut.csv, top10_corrige.csv, cambriolages_2024.csv
# (ces fichiers sont produits par episode_01.qmd)
# ====================================================================

library(ggplot2)
library(dplyr)
library(scales)

# Chemins relatifs depuis episodes/01_cambriolages/scrollytelling/R/
DATA_DIR <- "../.."
OUT_DIR  <- "../svg"
dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)

cambri      <- read.csv(file.path(DATA_DIR, "cambriolages_2024.csv"))
top_brut    <- read.csv(file.path(DATA_DIR, "top10_brut.csv"))
top_corrige <- read.csv(file.path(DATA_DIR, "top10_corrige.csv"))

# Palette
COL_POINTS    <- "#B8C5D0"
COL_HIGHLIGHT <- "#E74C3C"
COL_HIGH_2    <- "#27AE60"
COL_BAND      <- "#F4E4D6"
COL_TEXT      <- "#2C3E50"
COL_DEEP      <- "#1F4E79"

# Thème commun
theme_scrolly <- theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", color = COL_TEXT, size = 13, hjust = 0),
    plot.title.position = "plot",
    plot.caption = element_text(color = "#888", size = 9, hjust = 0),
    axis.title = element_text(color = COL_TEXT),
    axis.text = element_text(color = COL_TEXT),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "#E5E5E5", size = 0.4),
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA)
  )

# Échelles communes
x_breaks  <- c(100, 300, 1000, 10000, 100000, 1000000)
x_labels  <- c("100", "300", "1 000", "10 000", "100 000", "1 M")
x_limits  <- c(50, 3000000)
y_limits  <- c(-2, 75)

base_scatter <- function(highlight_layer = NULL, alpha_cloud = 0.45) {
  p <- ggplot(cambri, aes(x = population, y = taux_pour_mille)) +
    geom_point(color = COL_POINTS, alpha = alpha_cloud, size = 0.6) +
    scale_x_log10(breaks = x_breaks, labels = x_labels, limits = x_limits) +
    scale_y_continuous(breaks = seq(0, 70, 10), limits = y_limits) +
    labs(x = "Population de la commune (échelle logarithmique)",
         y = "Cambriolages pour 1 000 logements",
         caption = "Source : SSMSI / data.gouv.fr") +
    theme_scrolly
  if (!is.null(highlight_layer)) p <- p + highlight_layer
  p
}

save_svg <- function(plot, name, width = 9, height = 5.5) {
  svglite::svglite(file.path(OUT_DIR, name), width = width, height = height)
  print(plot)
  dev.off()
  message("  → ", name)
}

# ===== 01 : nuage de base =====
p1 <- base_scatter() +
  labs(title = "Toutes les communes pour lesquelles le SSMSI publie un taux 2024",
       caption = "10 951 communes  •  Source : SSMSI / data.gouv.fr")
save_svg(p1, "01_scatter_base.svg")

# ===== 02 : Vieille-Toulouse =====
vt <- cambri[cambri$nom_commune == "Vieille-Toulouse", ]
p2 <- base_scatter() +
  geom_point(data = vt, color = COL_HIGHLIGHT, size = 4) +
  annotate("text", x = 8000, y = 64, hjust = 0,
           label = "Vieille-Toulouse\n1 230 hab. • 37 cambriolages\n67,9 ‰",
           color = COL_HIGHLIGHT, fontface = "bold", size = 3.6) +
  annotate("segment", x = 8000, xend = vt$population,
           y = 64, yend = vt$taux_pour_mille,
           color = COL_HIGHLIGHT, size = 0.4) +
  labs(title = "La commune championne 2024")
save_svg(p2, "02_scatter_vieille_toulouse.svg")

# ===== 03 : Top 10 brut =====
p3 <- base_scatter(alpha_cloud = 0.30) +
  geom_point(data = top_brut, color = COL_HIGHLIGHT, size = 3) +
  labs(title = "Les 10 communes officiellement les plus cambriolées en 2024")
# Annotations sélectives ajoutées via annotate()
labels_brut <- list(
  list(name = "Vieille-Toulouse",        x = 8000,  y = 60),
  list(name = "Saugon",                  x = 95,    y = 50),
  list(name = "Boissettes",              x = 95,    y = 42),
  list(name = "Saint-Germain-du-Corbéis", x = 12000, y = 34)
)
for (lab in labels_brut) {
  pt <- top_brut[top_brut$nom_commune == lab$name, ]
  if (nrow(pt) > 0) {
    p3 <- p3 +
      annotate("segment", x = lab$x, xend = pt$population,
               y = lab$y, yend = pt$taux_pour_mille,
               color = COL_HIGHLIGHT, size = 0.3, alpha = 0.7) +
      annotate("text", x = lab$x, y = lab$y, hjust = 0,
               label = lab$name, color = COL_HIGHLIGHT, fontface = "bold", size = 3.2)
  }
}
p3 <- p3 +
  annotate("label", x = 1500000, y = 70, hjust = 1, vjust = 1,
           label = "9 sur 10 ont moins de 4 000 habitants.",
           color = COL_HIGHLIGHT, fontface = "bold", size = 3.6,
           label.size = 0.5)
save_svg(p3, "03_scatter_top10_brut.svg")

# ===== 04 : grandes métropoles =====
big_cities <- cambri[cambri$nom_commune %in%
  c("Paris", "Marseille", "Lyon", "Lille", "Bordeaux", "Toulouse", "Nantes", "Strasbourg"), ]

p4 <- base_scatter(alpha_cloud = 0.35) +
  annotate("rect", xmin = 10000, xmax = 3000000, ymin = -2, ymax = 75,
           fill = COL_BAND, alpha = 0.25) +
  geom_point(data = top_brut, color = COL_HIGHLIGHT, size = 2.2, alpha = 0.30) +
  geom_point(data = big_cities, color = COL_DEEP, size = 4) +
  annotate("text", x = 10500, y = 67, hjust = 0, vjust = 1,
           label = "≥ 10 000 habitants : la zone\noù un taux annuel veut\ndire quelque chose",
           color = "#9B5A2D", size = 3.4) +
  labs(title = "Les grandes métropoles n'apparaissent jamais dans le palmarès brut")
save_svg(p4, "04_scatter_metropoles.svg")

# ===== 05 : seuil 10 000 =====
left  <- cambri[cambri$population <  10000, ]
right <- cambri[cambri$population >= 10000, ]
p5 <- ggplot() +
  annotate("rect", xmin = 50, xmax = 10000, ymin = -2, ymax = 75,
           fill = "#999", alpha = 0.15) +
  geom_point(data = left,  aes(population, taux_pour_mille),
             color = COL_POINTS, alpha = 0.15, size = 0.6) +
  geom_point(data = right, aes(population, taux_pour_mille),
             color = COL_POINTS, alpha = 0.7, size = 0.7) +
  geom_vline(xintercept = 10000, color = "#34495E",
             linetype = "dashed", size = 0.7) +
  annotate("text", x = 10500, y = 65, hjust = 0, vjust = 1,
           label = "Seuil méthodologique\n10 000 habitants",
           color = "#34495E", fontface = "bold", size = 3.4) +
  annotate("text", x = 8500, y = 35, hjust = 1,
           label = "TROP PETIT\npour qu'un taux\nannuel soit fiable",
           color = "#666", fontface = "bold.italic", size = 3.6) +
  annotate("text", x = 11500, y = 35, hjust = 0,
           label = "1 116 communes\nrestantes",
           color = COL_TEXT, fontface = "bold", size = 3.6) +
  scale_x_log10(breaks = x_breaks, labels = x_labels, limits = x_limits) +
  scale_y_continuous(breaks = seq(0, 70, 10), limits = y_limits) +
  labs(x = "Population de la commune (échelle logarithmique)",
       y = "Cambriolages pour 1 000 logements",
       title = "On retire les communes où le hasard parle plus fort que la sociologie",
       caption = "Source : SSMSI / data.gouv.fr") +
  theme_scrolly
save_svg(p5, "05_scatter_seuil.svg")

# ===== 06 : top 10 corrigé =====
p6 <- ggplot() +
  annotate("rect", xmin = 50, xmax = 10000, ymin = -2, ymax = 75,
           fill = "#999", alpha = 0.12) +
  geom_point(data = left,  aes(population, taux_pour_mille),
             color = COL_POINTS, alpha = 0.12, size = 0.5) +
  geom_point(data = right, aes(population, taux_pour_mille),
             color = COL_POINTS, alpha = 0.55, size = 0.6) +
  geom_vline(xintercept = 10000, color = "#34495E",
             linetype = "dashed", alpha = 0.6) +
  geom_point(data = top_corrige, aes(population, taux_pour_mille),
             color = COL_HIGH_2, size = 3.5) +
  scale_x_log10(breaks = x_breaks, labels = x_labels, limits = x_limits) +
  scale_y_continuous(breaks = seq(0, 70, 10), limits = y_limits) +
  labs(x = "Population de la commune (échelle logarithmique)",
       y = "Cambriolages pour 1 000 logements",
       title = "Le palmarès quand on n'inclut que les communes ≥ 10 000 habitants",
       caption = "Source : SSMSI / data.gouv.fr") +
  annotate("label", x = 1500000, y = 70, hjust = 1, vjust = 1,
           label = "Banlieues pavillonnaires aisées + Guyane.\n7 sur 10 sont des périphéries de métropoles.",
           color = "#1A6E3A", fontface = "bold", size = 3.4,
           label.size = 0.5) +
  theme_scrolly
save_svg(p6, "06_scatter_top10_corrige.svg")

message("Scatter SVG : OK (6 fichiers)")
