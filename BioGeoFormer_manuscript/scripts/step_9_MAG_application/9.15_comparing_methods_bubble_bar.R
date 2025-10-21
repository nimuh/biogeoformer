library(dplyr)
library(stringr)
library(tidyverse)


setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()



short_pathways <- c(
  #methane cycle
  "cenmetpat",
  "cenmetpat,aom",
  "hydro_met", 
  "aceti_met", 
  "methyl_met",
  "aom", 
  "oxid_met_c1",
  "oxid_formaldehyde",
  "oxid_formate",
  "serine",
  "rump",
  
  
  # nitrogen cycles
  "nitrification", 
  "denitrification", 
  "assnitred", 
  "dissnitred", 
  "nitfix", 
  "annamox", 
  "odegsyn", 
  "nitrogen_other",
  
  
  # phosphorus cycles 
  "pyruvate", 
  "pentose", 
  "phosphotransferase", 
  "ox_phosphorylation", 
  "phosph_met", 
  "two_comp", 
  "transporters", 
  "org_phos_hyd",
  "phos_other", 
  "purine", 
  "pyrimidine",
  
  #sulfur cycles 
  "asssulred",
  "dsro",
  "sulred",
  "SOX", 
  "sulfur_ox", 
  "sulfur_dis", 
  "org_sul_trans", 
  "in_or_sul",  
  "sul_other")

long_pathways <- c("Central methanogenic pathway", 
                   "Central methanogenic pathway, AOM",
                   "Hydrogenotrophic methanogenesis", 
                   "Aceticlastic methanogenesis", 
                   "Methylotrophic methanogenesis", 
                   "Anaerobic oxidation of methane (AOM)", 
                   "Oxidation of methane and C1 compounds", 
                   "Oxidation of formaldehyde", 
                   "Oxidation of formate", 
                   "Serine cycle", 
                   "RuMP cycle", 
                   
                   
                   "Nitrification",
                   "Denitrication",
                   "Assimilatory nitrate reduction",
                   "Dissimilatory nitrate reduction",
                   "Nitrogen fixation",
                   "Annamox",
                   "Organic degradation and synthesis",
                   "Related Nitrogen genes",
                   
                   
                   "Pyruvate metabolism",
                   "Pentose phosphate pathway",
                   "Phosphotransferase system",
                   "Oxidative phosphorylation",
                   "Phosphonate and phosphinate metabolism",
                   "Two-component system",
                   "Transporters",
                   "Organic phosphoester hydrolysis",
                   "Related phosphorus genes",
                   "Purine metabolism",
                   "Pyrimidine metabolism",
                   
                   
                   "Assimilatory sulphate reduction",
                   "Dissimilatory sulphur reduction and oxidation",
                   "Sulphur reduction",
                   "SOX systems",
                   "Sulphur oxidation",
                   "Sulphur disproportionation",
                   "Organic sulphur transformation",
                   "Linkages between inorganic and organic sulphur transformation",
                   "Related sulphur genes"
                   
)


short_pathways <- as.data.frame(short_pathways)
long_pathways <- as.data.frame(long_pathways)

pathwaymap <- cbind(short_pathways, long_pathways)


joined_predictions <- read.csv("../../cold_seep_MAG_application/joined_predictions_coldseep_mags.csv")

long_preds <- joined_predictions %>%
  pivot_longer(
    cols = starts_with("prediction_"),
    names_to = "method",
    names_prefix = "prediction_",
    values_to = "pathway"
  ) %>%
  filter(!is.na(pathway))  # Remove NAs

# Step 3: Map short names to long pathway names
# Assume you have a dataframe `pathwaymap` with short to long names
long_preds <- left_join(long_preds, pathwaymap, by = c("pathway" = "short_pathways")) %>%
  mutate(pathway = long_pathways) %>%
  select(-long_pathways)

# Step 4: Count occurrences
pathway_counts <- long_preds %>%
  group_by(pathway, method) %>%
  summarise(count = n(), .groups = "drop")

# Step 5: Rename methods for display
pathway_counts <- pathway_counts %>%
  mutate(method = recode(method,
                         "diamond" = "Alignment",
                         "cycformer" = "Cycformer",
                         "hmm" = "HMM",
                         "kegg" = "KEGG"))

# Step 6: Assign cycles to each pathway
long_pathways <- c(
  ## methane
  "Central methanogenic pathway" = "Methane",
  "Central methanogenic pathway, AOM" = "Methane",
  "Hydrogenotrophic methanogenesis" = "Methane",
  "Aceticlastic methanogenesis" = "Methane",
  "Methylotrophic methanogenesis" = "Methane",
  "Anaerobic oxidation of methane (AOM)" = "Methane",
  "Oxidation of methane and C1 compounds" = "Methane",
  "Oxidation of formaldehyde" = "Methane",
  "Oxidation of formate" = "Methane",
  "Serine cycle" = "Methane",
  "RuMP cycle" = "Methane",
  ## nitrogen
  "Nitrification" = "Nitrogen",
  "Denitrication" = "Nitrogen",
  "Assimilatory nitrate reduction" = "Nitrogen",
  "Dissimilatory nitrate reduction" = "Nitrogen",
  "Nitrogen fixation" = "Nitrogen",
  "Annamox" = "Nitrogen",
  "Organic degradation and synthesis" = "Nitrogen",
  "Related Nitrogen genes" = "Nitrogen",
  ## phosphorus
  "Pyruvate metabolism" = "Phosphorus",
  "Pentose phosphate pathway" = "Phosphorus",
  "Phosphotransferase system" = "Phosphorus",
  "Oxidative phosphorylation" = "Phosphorus",
  "Phosphonate and phosphinate metabolism" = "Phosphorus",
  "Two-component system" = "Phosphorus",
  "Transporters" = "Phosphorus",
  "Organic phosphoester hydrolysis" = "Phosphorus",
  "Related phosphorus genes" = "Phosphorus",
  "Purine metabolism" = "Phosphorus",
  "Pyrimidine metabolism" = "Phosphorus",
  ## sulphur
  "Assimilatory sulphate reduction" = "Sulphur",
  "Dissimilatory sulphur reduction and oxidation" = "Sulphur",
  "Sulphur reduction" = "Sulphur",
  "SOX systems" = "Sulphur",
  "Sulphur oxidation" = "Sulphur",
  "Sulphur disproportionation" = "Sulphur",
  "Organic sulphur transformation" = "Sulphur",
  "Linkages between inorganic and organic sulphur transformation" = "Sulphur",
  "Related sulphur genes" = "Sulphur"
)

pathway_counts <- pathway_counts %>%
  mutate(cycle = recode(pathway, !!!long_pathways))

pathway_counts <- filter(pathway_counts, !is.na(cycle))

# Step 7: Plot
bubble_plot <- ggplot(pathway_counts, aes(x = method, y = pathway, size = count, color = cycle)) + 
  geom_point(alpha = 0.7) +
  xlab("Prediction Method") +
  ylab("Metabolic Pathway") +
  theme_minimal() +
  theme(axis.text = element_text(size = 12.5),
        axis.title = element_text(size = 14),
        plot.title = element_text(size = 16, hjust = 0.5),
        legend.position = "right") +
  scale_size_continuous(name = "Gene Count", range = c(3, 15))


ggsave("../../results/figures/bubble_plot.png", bubble_plot, width = 10.5, height = 9, dpi = 600)


comparison <- pathway_counts %>%
  pivot_wider(names_from = method, values_from = count) %>%
  mutate(
    vs_Alignment = Cycformer/Alignment ,
    vs_HMM       = Cycformer/ HMM ,
    vs_KEGG      = Cycformer/KEGG
  ) %>%
  select(cycle, pathway, starts_with("vs_"))

write.csv(comparison, "../../results/tables/summary_stats_comparison.csv")

print(comparison)


median_comparison <- comparison %>%
  summarise(
    median_vs_Alignment = median(vs_Alignment, na.rm = TRUE),
    median_vs_HMM       = median(vs_HMM, na.rm = TRUE),
    median_vs_KEGG      = median(vs_KEGG, na.rm = TRUE)
  )

print(median_comparison)


mean_comparison <- comparison %>%
  summarise(
    mean_vs_Alignment = mean(vs_Alignment, na.rm = TRUE),
    mean_vs_HMM       = mean(vs_HMM, na.rm = TRUE),
    mean_vs_KEGG      = mean(vs_KEGG, na.rm = TRUE)
  )

print(mean_comparison)






selected_pathways <- c(
  "Two-component system",
  "Transporters",
  "Sulphur reduction",
  "Nitrification",
  "Denitrication",
  "Central methanogenic pathway",
  "Aceticlastic methanogenesis"
)

# Filter the dataset
filtered_pathway_data <- pathway_counts %>%
  filter(pathway %in% selected_pathways)


bubble_plot_filtered <- ggplot(filtered_pathway_data, aes(x = method, y = pathway, size = count, color = cycle)) + 
  geom_point(alpha = 0.7) +
  xlab("Prediction Method") +
  ylab("Metabolic Pathway") +
  theme_minimal() +
  theme(axis.text = element_text(size = 12.5),
        axis.title = element_text(size = 14),
        plot.title = element_text(size = 16, hjust = 0.5),
        legend.position = "right") +
  scale_size_continuous(name = "Gene Count", range = c(3, 15))




df <- read.csv("../../cold_seep_MAG_application/model_predictions_mags_allmodels_df.csv")


library(dplyr)
library(ggplot2)

# 1. Subset to only Cycformer predictions
cycformer_only <- df %>%
  filter(!is.na(prediction_cycformer) &                 # cycformer made a call
           is.na(prediction_diamond) & 
           is.na(prediction_hmm) & 
           is.na(prediction_kegg)) %>%
  select(query_id, prediction_cycformer)

# 2. Count number of cycles predicted
cycle_counts <- cycformer_only %>%
  count(prediction_cycformer, name = "n")

cycle_counts_long <- cycle_counts %>%
  left_join(pathwaymap, by = c("prediction_cycformer" = "short_pathways")) %>%
  mutate(pathway = ifelse(is.na(long_pathways), prediction_cycformer, long_pathways)) %>%
  select(pathway, n)

cycle_counts_long

cycle_counts_long <- cycle_counts_long %>%
  bind_rows(data.frame(pathway = "Nitrification", n = 0)) %>%
  distinct(pathway, .keep_all = TRUE)

cycle_counts_long <- cycle_counts_long %>%
  mutate(cycle = recode(pathway, !!!long_pathways))



library(ggplot2)
library(patchwork)


pathway_counts <- pathway_counts %>%
  mutate(method = recode(method,
                         "Alignment"   = "DIAMOND-BGFdb",
                         "HMM"       = "HMM",
                         "KEGG"      = "DIAMOND-KEGG",
                         "Cycformer" = "BGF"
  ))


pathway_counts$method <- factor(
  pathway_counts$method,
  levels = c("DIAMOND-BGFdb", "BGF", "HMM", "DIAMOND-KEGG")
)



bubble_plot <- ggplot(pathway_counts, aes(x = method, y = pathway, size = count, color = cycle)) + 
  geom_point(alpha = 0.7) +
  xlab(NULL) +
  ylab(NULL) +   # removed y-axis label
  theme_minimal() +
  theme(
    axis.text.y.left = element_text(size = 12.5),
    axis.text.x.bottom = element_text(
      size = 12.5, 
      angle = 45, 
      vjust = 1,             # vertical adjust (1 = down/right for angled text)
      hjust = 1,             # horizontal adjust (1 = right align)
      margin = margin(t = 8) # 👈 add top margin to push text down
    ), 
    axis.title.x = element_text(size = 14),
    plot.title = element_text(size = 16, hjust = 0.5),
    
    # Legend tweaks
    legend.position = "left",
    legend.justification = "top",
    legend.box.just = "left",
    legend.margin = margin(0, 0, 0, 0),         # shrink inside spacing
    legend.box.margin = margin(r = -15, l = -5), # pull closer to plot
    
    # Bigger cycle legend
    legend.text = element_text(size = 14),
    legend.title = element_text(size = 16),
    legend.key.size = unit(1.2, "cm"),
    legend.spacing.y = unit(0.5, "cm"),
    
    panel.grid.major.y = element_line(color = "grey80"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank()
  ) +
  scale_size_continuous(name = "Gene Count", range = c(3, 15))

# Bar plot (to the right)
bar_plot <- ggplot(cycle_counts_long, aes(x = n, y = pathway, fill = cycle)) +
  geom_col(color = NA) +   # no bold black border
  labs(x = "Unique BGF Predictions", y = NULL) +
  theme_minimal(base_size = 14) +
  theme(
    axis.text.y = element_blank(),    # hide y text
    axis.ticks.y = element_blank(),   # hide ticks
    axis.title.y = element_blank(),   # no y title
    panel.grid.major.y = element_line(color = "grey80"),  # same horizontal grid
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "none"
  )


combined <- bubble_plot + bar_plot + plot_layout(widths = c(3, 1.6))
combined



ggsave("../../results/figures/bubble_plot_andbar.png", combined, width = 12, height = 9, dpi = 600)



ggsave("../../results/figures/bubble_plot_filtered.png", bubble_plot_filtered, width = 7, height = 4, dpi = 600)


bubble_plot_filtered <- ggplot(filtered_pathway_data, aes(x = method, y = pathway, size = count, color = cycle)) + 
  geom_point(alpha = 0.7) +
  xlab("Prediction Method") +
  ylab("Metabolic Pathway") +
  theme_minimal() +
  theme(
    axis.text = element_text(size = 12.5),
    axis.text.x = element_text(angle = 45, hjust = 1),  # angled x-axis
    axis.title = element_text(size = 14),
    plot.title = element_text(size = 16, hjust = 0.5),
    legend.position = "right"
  ) +
  scale_size_continuous(name = "Gene Count", range = c(3, 15))

ggsave("../../results/figures/bubble_plot_filtered.png", bubble_plot_filtered, width = 7, height = 4, dpi = 600)




# Count non-NA predictions per method from the same `joined_predictions` dataframe
annotation_counts <- joined_predictions %>%
  pivot_longer(
    cols = starts_with("prediction_"),
    names_to = "method",
    names_prefix = "prediction_",
    values_to = "pathway"
  ) %>%
  filter(!is.na(pathway)) %>%
  count(method) %>%
  mutate(method = recode(method,
                         "diamond" = "Diamond",
                         "cycformer" = "Cycformer",
                         "hmm" = "HMM",
                         "kegg" = "KEGG"))

# Plot barplot of total annotations per method
library(scales)

# Reorder method factor
annotation_counts$method <- factor(annotation_counts$method, levels = c("KEGG", "Cycformer", "Diamond", "HMM"))

# Custom scientific formatter
sci_labeller <- function(x) {
  parse(text = gsub("e\\+?", " %*% 10^", scientific_format()(x)))
}

# Plot
barplot_total <- ggplot(annotation_counts, aes(x = method, y = n)) +
  geom_col(fill = "#333333", alpha = 0.9) +
  coord_flip() +
  scale_y_continuous(labels = sci_labeller) +  # <- fixed scientific format
  labs(x = "", y = "Total Gene Annotations", title = " ") +
  theme_minimal() +
  theme(
    axis.text = element_text(size = 12),
    axis.title = element_text(size = 14),
    plot.title = element_text(size = 16, hjust = 0.5),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "none"
  )

# Save at high resolution
ggsave("../../results/figures/barplot.png", barplot_total, width = 9, height = 5, dpi = 600)


ggsave(
  "../../results/figures/barplot.svg",
  barplot_total,
  width = 9,
  height = 5
)



