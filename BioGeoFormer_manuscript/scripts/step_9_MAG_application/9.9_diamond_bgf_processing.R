
library(dplyr)
library(readr)
library(stringr)
library(purrr)
library(ggplot2)


setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()


#mags_cycformer <- read.csv("mags_fc_annotated.csv")


# Read the DIAMOND output file into a dataframe
df <- read.table("../../cold_seep_MAG_application/DIAMOND_BGF_output/mags_diamond_output_sep10.m8", header = FALSE, sep = "\t")

# View the first few rows of the dataframe
head(df)


# Assign meaningful column names based on the DIAMOND output format
colnames(df) <- c("query_id", "subject_id", "percent_identity", "alignment_length", 
                            "mismatches", "gap_openings", "q_start", "q_end", "s_start", 
                            "s_end", "e_value", "bit_score")




# Define the path to the gene map file
combined_csv <- "../../BioGeoFormer_db/BioGeoFormer_db.csv"


# Read the gene map into a data frame
gene_map <- read_csv(combined_csv)

colnames(gene_map) <- c("ProteinID", "Gene", "Cycle", "Sequence")



df_filtered <- df %>% filter(e_value <= 1e-5, 
                             percent_identity >= 50,
                             bit_score >= 50)


df_best_match <- df_filtered %>%
  group_by(query_id) %>%
  arrange(desc(bit_score), e_value, desc(percent_identity)) %>%
  slice(1) %>%
  ungroup()



## Merge the dataframes by 'subject_id' and 'ProteinID'
merged_df <- merge(df_best_match, gene_map, by.x = "subject_id", by.y = "ProteinID", all.x = TRUE)
#


# Count the occurrences of each gene
gene_counts <- merged_df %>% count(Gene)



write.csv(merged_df, "../../cold_seep_MAG_application/DIAMOND_BGF_processed/DIAMOND_BGF_mags_processed.csv", row.names = FALSE)

gene_map_unique <- gene_map %>% distinct(Gene, Cycle)

agg_counts_path <- gene_counts %>%
  left_join(gene_map_unique, by = "Gene") %>%
  group_by(Cycle) %>%
  summarise(gene_count = sum(n, na.rm = TRUE), .groups = "drop") %>%
  arrange(desc(gene_count))


