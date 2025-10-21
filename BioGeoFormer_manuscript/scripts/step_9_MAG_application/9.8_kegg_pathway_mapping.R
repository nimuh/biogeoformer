library(dplyr)
library(tidyr)
library(ggplot2)



setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()


kegg_annotated_mags <- read.csv("../../cold_seep_MAG_application/KEGG_processed/MAGS_annotated_50.csv")

kegg_annotated_mags <- select(kegg_annotated_mags, -Gene)


ko_gene_mapping <- read.csv("../../cold_seep_MAG_application/KEGG_mapping/full_gene_ko_mapping.csv")

ko_gene_mapping <- select(ko_gene_mapping, KO, gene)

ko_gene_mapping <- unique(ko_gene_mapping) 

ko_gene_mapping <- ko_gene_mapping %>%
  filter(!is.na(KO))

colnames(ko_gene_mapping) <- c("KO", "Gene")

combined_ml <- read.csv("../../BioGeoFormer_db/BioGeoFormer_db.csv")


gene_cycle_df <- select(combined_ml, gene, cycle)

gene_cycle_df <- unique(gene_cycle_df)

rm(combined_ml)
gc()  


colnames(gene_cycle_df) <- c("Gene", "Pathway")




kegg_annotated_mapped <- kegg_annotated_mags %>%
  left_join(ko_gene_mapping, by = "KO")

kegg_annotated_mapped_path <- kegg_annotated_mapped %>% 
  left_join(gene_cycle_df, by = "Gene")


kegg_annotated_biogeo <- kegg_annotated_mapped_path %>% 
  filter(!is.na(Pathway))

pathway_counts <- kegg_annotated_biogeo %>%
  count(Pathway, sort = TRUE)


write.csv(kegg_annotated_biogeo, "../../cold_seep_MAG_application/KEGG_processed/kegg_annotated_withpathways.csv", row.names = FALSE)


