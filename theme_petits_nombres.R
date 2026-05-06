# Palette et thème ggplot partagés pour toute la série
# Usage : source("../../theme_petits_nombres.R") depuis un épisode,
#         ou source("theme_petits_nombres.R") depuis la racine.

palette_strates <- c(
  "1. < 300 hab. (effet petits nombres maximal)" = "#FF6B6B",
  "2. 300 – 1 000 hab."                         = "#FFB347",
  "3. 1 000 – 10 000 hab."                       = "#4A9EBD",
  "4. 10 000 – 100 000 hab."                     = "#5DADE2",
  "5. > 100 000 hab. (loi des grands nombres)"   = "#1F4E79"
)

theme_petits_nombres <- function(base_size = 12) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      text             = ggplot2::element_text(family = "Helvetica"),
      plot.title       = ggplot2::element_text(face = "bold", size = base_size + 2),
      plot.subtitle    = ggplot2::element_text(color = "#555555", size = base_size - 1),
      plot.caption     = ggplot2::element_text(color = "#888888", size = base_size - 3,
                                               hjust = 0),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(color = "#E8E8E8")
    )
}
