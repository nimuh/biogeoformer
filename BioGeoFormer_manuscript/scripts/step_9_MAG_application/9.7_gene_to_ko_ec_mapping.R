library(tidyverse)


setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()


combined_ml <- read.csv("../../BioGeoFormer_db/BioGeoFormer_db.csv")


gene_cycle_df <- select(combined_ml, gene, cycle)
# Load required library

# 2. Load KO annotation table
ko_df <- read.csv("../../cold_seep_MAG_application/KEGG_mapping/parsed_ko00001.csv", stringsAsFactors = FALSE)

colnames(ko_df)

colnames(ko_df) <- c("KO", "Gene_Symbols", "Description", "EC", "Hierarchy")


# 3. Tidy: separate multiple gene symbols into rows
ko_long <- ko_df %>%
  rename(gene = Gene_Symbols) %>%
  separate_rows(gene, sep = ",\\s*")


# 4. Create full mapping: includes all KO matches per gene
full_mapping <- gene_cycle_df %>%
  left_join(ko_long, by = "gene")

# 5. Create conserved mapping: only keep genes mapping to exactly one KO
conserved_ko_genes <- ko_long %>%
  group_by(gene) %>%
  filter(n_distinct(KO) == 1) %>%
  distinct(gene, KO) %>%
  ungroup()

# 6. Join conserved mappings
conserved_mapping <- gene_cycle_df %>%
  inner_join(conserved_ko_genes, by = "gene") %>%
  left_join(ko_df, by = "KO")  # add full KO info

full_mapping <- select(full_mapping, -Hierarchy)

full_mapping <- unique(full_mapping)

conserved_mapping <- select(conserved_mapping, -Hierarchy)
conserved_mapping <- unique(conserved_mapping)

# 7. Save outputs
write.csv(full_mapping, "../../cold_seep_MAG_application/KEGG_mapping/full_gene_ko_mapping.csv", row.names = FALSE)
write.csv(conserved_mapping, "../../cold_seep_MAG_application/KEGG_mapping/genes_ko_ec_mappingconserved_gene_ko_mapping.csv", row.names = FALSE)

# Print a summary
cat("Full mapping includes:", nrow(full_mapping), "rows\n")
cat("Conserved mapping includes:", nrow(conserved_mapping), "rows\n")




