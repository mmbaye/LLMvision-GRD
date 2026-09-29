# ============================================================
# Authors Modou et Ivan
# Figure : matrices de confusion, effectifs + % par ligne (comm. 15)
# Deux figures séparées : P02 et P03, chacune avec les quatre modèles
# Lit ../03_results/confusion_matrices_long.csv (produit par grd_classwise_metrics.R)
#
# Usage : Rscript grd_figure_confusion.R
# ============================================================

suppressMessages({ library(ggplot2); library(dplyr); library(readr) })

CSV     <- "../03_results/confusion_matrices_long.csv"
OUT_DIR <- "../02_figures"
MODEL_ORDER <- c("Claude", "Ministral", "Qwen3-VL", "VIPS")
COND_LABS   <- c(P02 = "P02 | Image only", P03 = "P03 | YOLO-augmented")

d <- read_csv(CSV, show_col_types = FALSE)

# étiquettes de l'axe référence avec effectifs : "GRD5 (n=75)"
ref_n <- d %>% distinct(ref, row_n) %>% group_by(ref) %>% summarise(n = max(row_n), .groups = "drop")
ref_labs <- setNames(sprintf("GRD%d (n=%d)", ref_n$ref, ref_n$n), ref_n$ref)

d <- d %>%
  mutate(model = factor(model, levels = MODEL_ORDER),
         condition = factor(condition, levels = names(COND_LABS), labels = COND_LABS),
         ref  = factor(ref,  levels = 5:1, labels = ref_labs[as.character(5:1)]),
         pred = factor(pred, levels = 1:5, labels = paste0("GRD", 1:5)),
         lab  = ifelse(count == 0, "", sprintf("%d\n(%.0f%%)", count, row_pct)),
         diag = as.integer(pred) == 6 - as.integer(ref))

make_figure <- function(condition_label) {
  panel_data <- filter(d, condition == condition_label)
  if (nrow(panel_data) == 0L) stop("Aucune donnée pour : ", condition_label)
  
  ggplot(panel_data, aes(x = pred, y = ref, fill = row_pct)) +
    geom_tile(color = "white", linewidth = 0.6) +
    geom_tile(data = filter(panel_data, diag), fill = NA, color = "grey20", linewidth = 0.5) +
    geom_text(aes(label = lab, color = row_pct > 60), size = 2.6, lineheight = 0.85) +
    scale_fill_gradient(low = "#deebf7", high = "#3182bd", limits = c(0, 100),
                        na.value = "grey95", name = "Row %") +
    scale_color_manual(values = c(`FALSE` = "grey15", `TRUE` = "white"), guide = "none") +
    facet_grid(. ~ model, drop = FALSE) +
    labs(title = condition_label, x = "Predicted GRD class (VLM)", 
         y = "Reference class (YOLO SEG-area)"
         # caption = "Cells: count (row percentage). Outlined cells: exact agreement. N = 107 images per panel."
    ) +
    theme_minimal(base_size = 10) +
    theme(panel.grid = element_blank(),
          strip.text = element_text(face = "bold", size = 10),
          axis.text.x = element_text(angle = 45, hjust = 1, size = 10, face='bold'),
          axis.text.y = element_text(size = 10, face='bold'),
          # plot.caption = element_text(size = 8, color = "grey40"),
          legend.position = "right")
  
}

# Même échelle de couleurs (0 à 100 %) pour comparer les conditions.
fig_P02 <- make_figure(COND_LABS[["P02"]])
fig_P03 <- make_figure(COND_LABS[["P03"]])

dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)

ggsave(file.path(OUT_DIR, "Figure_confusion_matrices_P02.png"),
       fig_P02, width = 12, height = 3.8, dpi = 300, bg = "white")
ggsave(file.path(OUT_DIR, "Figure_confusion_matrices_P03.png"),
       fig_P03, width = 12, height = 3.8, dpi = 300, bg = "white")

print(fig_P02)
print(fig_P03)

