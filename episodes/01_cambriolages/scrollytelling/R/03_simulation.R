# ====================================================================
# Simulation pédagogique de la loi des petits nombres :
# 1 000 communes parfaitement identiques (même p réelle) →
# observe-t-on un palmarès quand n est petit ? Quand n est grand ?
#
# Sortie : 08_simulation_petit_n.svg, 09_simulation_grand_n.svg
# Niveau terminale spé maths : tirage Poisson(λ = n × p)
# ====================================================================

library(ggplot2)

OUT_DIR <- "../svg"
dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)

set.seed(42)

# Paramètres
p_vrai <- 0.005      # probabilité réelle = 5 ‰ (moyenne nationale)
N      <- 1000       # nombre de communes simulées

COL_POINTS <- "#B8C5D0"
COL_HIGHLIGHT <- "#E74C3C"
COL_DEEP <- "#1F4E79"
COL_TEXT <- "#2C3E50"

theme_sim <- theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", color = COL_TEXT, size = 12, hjust = 0),
    plot.title.position = "plot",
    plot.caption = element_text(color = "#888", size = 9, hjust = 0),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_line(color = "#E5E5E5", size = 0.4),
    axis.text.y = element_blank(),
    axis.title.y = element_blank(),
    axis.text.x = element_text(color = COL_TEXT),
    axis.title.x = element_text(color = COL_TEXT),
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA)
  )

# ===== 08 : petit n (200 logements) =====
n_petit <- 200
counts_petit <- rpois(N, lambda = n_petit * p_vrai)  # λ = 1
rates_petit  <- counts_petit / n_petit * 1000

sim_petit <- data.frame(
  rate = rates_petit,
  jitter = runif(N, 0, 1)
)

# Stats pour annotation
seuil_top <- quantile(rates_petit, 0.99)
xmax_petit <- max(rates_petit) + 5

p8 <- ggplot(sim_petit, aes(x = rate, y = jitter)) +
  annotate("rect", xmin = seuil_top, xmax = xmax_petit, ymin = -0.1, ymax = 1.4,
           fill = COL_HIGHLIGHT, alpha = 0.18) +
  geom_point(color = COL_POINTS, alpha = 0.5, size = 1.3) +
  geom_vline(xintercept = 5, color = COL_HIGHLIGHT, size = 0.8, linetype = "dashed") +
  annotate("text", x = 5, y = 1.20,
           label = "Taux « vrai »\nidentique pour les 1 000 communes",
           color = COL_HIGHLIGHT, fontface = "bold", size = 3.4) +
  annotate("text", x = (seuil_top + xmax_petit) / 2, y = 1.10,
           label = "« Communes les plus dangereuses »",
           color = COL_HIGHLIGHT, fontface = "bold.italic", size = 3.2) +
  scale_x_continuous(breaks = seq(0, 30, 5), limits = c(-1, xmax_petit)) +
  scale_y_continuous(limits = c(-0.1, 1.4)) +
  labs(x = "Taux observé (‰) — qui ne reflète QUE le hasard",
       y = NULL,
       title = paste0("1 000 communes IDENTIQUES de ", n_petit, " logements,\n",
                      "même probabilité réelle 5 ‰ — voici ce que produit le hasard"),
       caption = paste0("Simulation : tirage de Poisson(λ = ", n_petit * p_vrai, ") — n = ", N)) +
  theme_sim

svglite::svglite(file.path(OUT_DIR, "08_simulation_petit_n.svg"), width = 9, height = 5)
print(p8)
dev.off()
message("  → 08_simulation_petit_n.svg")

# ===== 09 : grand n (50 000 logements) =====
n_grand <- 50000
counts_grand <- rpois(N, lambda = n_grand * p_vrai)  # λ = 250
rates_grand  <- counts_grand / n_grand * 1000

sim_grand <- data.frame(
  rate = rates_grand,
  jitter = runif(N, 0, 1)
)

p9 <- ggplot(sim_grand, aes(x = rate, y = jitter)) +
  geom_point(color = COL_DEEP, alpha = 0.5, size = 1.3) +
  geom_vline(xintercept = 5, color = COL_HIGHLIGHT, size = 0.8, linetype = "dashed") +
  annotate("text", x = 5, y = 1.20,
           label = "Taux « vrai »\nidentique pour les 1 000 communes",
           color = COL_HIGHLIGHT, fontface = "bold", size = 3.4) +
  scale_x_continuous(breaks = seq(0, 30, 5), limits = c(-1, max(xmax_petit, 30))) +
  scale_y_continuous(limits = c(-0.1, 1.4)) +
  labs(x = "Taux observé (‰)",
       y = NULL,
       title = paste0("Mêmes 1 000 communes, mais cette fois ",
                      format(n_grand, big.mark = " "), " logements chacune\n",
                      "Le hasard se tasse autour de la vraie valeur"),
       caption = paste0("Simulation : tirage de Poisson(λ = ", n_grand * p_vrai, ") — n = ", N)) +
  theme_sim

svglite::svglite(file.path(OUT_DIR, "09_simulation_grand_n.svg"), width = 9, height = 5)
print(p9)
dev.off()
message("  → 09_simulation_grand_n.svg")

# ===== Stats imprimées (utiles pour le texte de la page) =====
cat("\n=== Stats simulation petit n (n =", n_petit, ") ===\n")
cat("  Min observé :", round(min(rates_petit), 2), "‰\n")
cat("  Max observé :", round(max(rates_petit), 2), "‰\n")
cat("  À 0 cambriolage :", sum(counts_petit == 0), "/", N, "\n")
cat("  À ≥ 15 ‰ :", sum(rates_petit >= 15), "/", N, "\n")
cat("  σ théorique = √(p/n) × 1000 =", round(sqrt(p_vrai / n_petit) * 1000, 2), "‰\n")
cat("\n=== Stats simulation grand n (n =", n_grand, ") ===\n")
cat("  Min observé :", round(min(rates_grand), 2), "‰\n")
cat("  Max observé :", round(max(rates_grand), 2), "‰\n")
cat("  σ théorique = √(p/n) × 1000 =", round(sqrt(p_vrai / n_grand) * 1000, 3), "‰\n")
