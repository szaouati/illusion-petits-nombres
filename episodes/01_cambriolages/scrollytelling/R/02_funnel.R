# ====================================================================
# Génère l'entonnoir méthodologique (07_funnel.svg) :
# 34 945 communes → 10 951 (taux diffusé) → 1 116 (≥ 10 000 hab)
# ====================================================================

library(ggplot2)

OUT_DIR <- "../svg"
dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)

stages <- data.frame(
  ordre = 1:3,
  label = c("Communes en France\n(INSEE 2025)",
            "Communes pour lesquelles le SSMSI\npublie un taux 2024",
            "Communes ≥ 10 000 habitants\n(seuil de fiabilité statistique)"),
  n     = c(34945, 10951, 1116),
  y     = c(0.85, 0.55, 0.20),
  w     = c(0.85, 0.55, 0.18),
  color = c("#B8C5D0", "#7FA8C4", "#1F4E79"),
  text_color = c("#2C3E50", "white", "white")
)

stages$xmin <- (1 - stages$w) / 2
stages$xmax <- (1 + stages$w) / 2
stages$ymin <- stages$y - 0.06
stages$ymax <- stages$y + 0.06
stages$n_fmt <- format(stages$n, big.mark = " ", scientific = FALSE)

p <- ggplot() +
  geom_rect(data = stages,
            aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax,
                fill = I(color)),
            alpha = 0.92) +
  geom_text(data = stages,
            aes(x = 0.5, y = y, label = n_fmt, color = I(text_color)),
            size = 9, fontface = "bold") +
  geom_text(data = stages,
            aes(x = 0.5, y = y - 0.10, label = label),
            size = 3.6, color = "#2C3E50", vjust = 1) +
  # Flèches entre étapes
  annotate("segment", x = 0.5, xend = 0.5, y = 0.78, yend = 0.62,
           arrow = arrow(length = unit(0.15, "cm")), color = "#999") +
  annotate("segment", x = 0.5, xend = 0.5, y = 0.48, yend = 0.27,
           arrow = arrow(length = unit(0.15, "cm")), color = "#999") +
  scale_x_continuous(limits = c(0, 1)) +
  scale_y_continuous(limits = c(0, 1)) +
  labs(title = "De 34 945 communes à 1 116 :\nl'entonnoir méthodologique",
       caption = "Sources : INSEE, SSMSI / data.gouv.fr") +
  theme_void() +
  theme(
    plot.title = element_text(face = "bold", color = "#2C3E50",
                              size = 13, hjust = 0.5, margin = margin(b = 10)),
    plot.caption = element_text(color = "#888", size = 9, hjust = 0)
  )

svglite::svglite(file.path(OUT_DIR, "07_funnel.svg"), width = 8, height = 5.5)
print(p)
dev.off()
message("  → 07_funnel.svg")
