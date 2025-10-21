library(dplyr)
library(readr)
library(stringr)
library(purrr)
library(data.table)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

setwd("../../diamond_run_val_test_anti_split/anti_split_output/")

# Define the column names for DIAMOND output
col_names <- c("query_id", "subject_id", "percent_identity", "alignment_length", 
               "mismatches", "gap_openings", "q_start", "q_end", "s_start", 
               "s_end", "e_value", "bit_score")

# Get all .m8 files in the directory
files <- list.files(pattern = "\\.m8$")

# Read all files into a named list of tibbles
diamond_list <- map(files, ~ read.table(.x, header = FALSE, sep = "\t", stringsAsFactors = FALSE) %>%
                      setNames(col_names) %>%
                      mutate(filename = .x) %>%
                      as_tibble()) %>%
  set_names(files)

# Example: look at one dataframe
head(diamond_list[["anti_split_full_100_vs_100.m8"]])

# Read in your combined ML dataset
combined_ml <- read.csv("../../BioGeoFormer_db/BioGeoFormer_db.csv")

# Keep only id, gene, cycle and rename once here
gene_cycle_df <- combined_ml %>%
  select(id, gene, cycle) %>%
  distinct() 
# Function: annotate query and subject using gene_cycle_df only
process_diamond_query_subject <- function(df, gene_cycle_df) {
  
  # Query side annotation
  query_annot <- gene_cycle_df %>%
    rename(query_id = id)
  
  # Subject side annotation
  subject_annot <- gene_cycle_df %>%
    rename(subject_id = id)
  
  # Merge annotations onto DIAMOND results
  df %>%
    left_join(query_annot, by = "query_id") %>%
    rename(query_gene = gene, query_cycle = cycle) %>%
    left_join(subject_annot, by = "subject_id") %>%
    rename(subject_gene = gene, subject_cycle = cycle)
}

# Apply to all DIAMOND dfs in your list (no filtering step!)
diamond_qs_annotated <- map(diamond_list,
                            process_diamond_query_subject,
                            gene_cycle_df = gene_cycle_df)

# Combine all annotated dfs into one dataframe with filename
diamond_all <- bind_rows(diamond_qs_annotated, .id = "source_file")




library(dplyr)
library(stringr)

merge_anti_with_diamond <- function(diamond_all, anti_dir) {
  # List and read anti_split CSVs
  csv_files <- list.files(anti_dir, pattern = "\\.csv$", full.names = TRUE)
  csv_data_list <- lapply(csv_files, read.csv, stringsAsFactors = FALSE)
  similarity_labels <- str_extract(basename(csv_files), "\\d+")
  names(csv_data_list) <- similarity_labels
  
  merged_anti_list <- lapply(names(csv_data_list), function(sim) {
    anti_df <- csv_data_list[[sim]] %>%
      rename(query_id = id,
             query_gene = gene,
             query_cycle = cycle)
    
    # Filter DIAMOND rows for this similarity
    diamond_sub <- diamond_all %>%
      filter(str_detect(source_file, paste0("_", sim, "_")))
    
    # FULL join so we keep everything
    merged <- full_join(anti_df, diamond_sub, by = "query_id") %>%
      mutate(
        subject_gene  = ifelse(is.na(subject_gene), "unassigned", subject_gene),
        subject_cycle = ifelse(is.na(subject_cycle), "unassigned", subject_cycle)
      )
    
    return(merged)
  })
  
  names(merged_anti_list) <- names(csv_data_list)
  return(merged_anti_list)
}

# Example usage:
anti_dir <- "../../BGF_clustering/anti_splits/"
merged_anti_list <- merge_anti_with_diamond(diamond_all, anti_dir)

# Inspect one similarity (100)
head(merged_anti_list[["100"]])


library(dplyr)

# Columns to keep
keep_cols <- c(
  "query_id", "query_gene.x", "query_cycle.x", "sequence", "source_file",
  "subject_id", "percent_identity", "e_value", "bit_score", "filename",
  "subject_gene", "subject_cycle"
)

# Apply to all dfs in the list
merged_anti_list <- lapply(merged_anti_list, function(df) {
  df %>%
    select(all_of(keep_cols)) %>%
    rename(
      query_gene = query_gene.x,
      query_cycle = query_cycle.x
    )
})



outdir <- "../../filtered_test_set/anti_split_fasta/"
if (!dir.exists(outdir)) dir.create(outdir)

# Define the similarity levels (must match order of merged_anti_list)
similarities <- c(100, 20, 30, 40, 50, 60, 70, 80, 90)

# Loop through each dataframe with its similarity
for (i in seq_along(merged_anti_list)) {
  
  df <- merged_anti_list[[i]] %>%
    select(query_id, sequence)
  
  # Use similarity in filename
  sim <- similarities[i]
  fasta_file <- file.path(outdir, paste0("merged_anti_split_", sim, ".fasta"))
  
  # Write FASTA
  con <- file(fasta_file, "w")
  apply(df, 1, function(row) {
    writeLines(paste0(">", row["query_id"], "\n", row["sequence"]), con)
  })
  close(con)
}








library(dplyr)

outdir <- "../../filtered_test_set/anti_split_csv/"
if (!dir.exists(outdir)) dir.create(outdir)

# Define the similarity levels (must match order of merged_anti_list)
similarities <- c(100, 20, 30, 40, 50, 60, 70, 80, 90)

# Loop through each dataframe with its similarity
for (i in seq_along(merged_anti_list)) {
  
  df <- merged_anti_list[[i]]  # keep all columns
  
  # Use similarity in filename
  sim <- similarities[i]
  csv_file <- file.path(outdir, paste0("merged_anti_split_", sim, ".csv"))
  
  # Write CSV
  write.csv(df, csv_file, row.names = FALSE)
}


























