library(dplyr)
library(readr)
library(stringr)
library(purrr)
library(data.table)


setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

setwd("../../diamond_run_val_test_anti_split/val_test_output/")

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
head(diamond_list[["final_selected_test_100_vs_100.m8"]])

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

# Split into test and val
test_df <- diamond_all %>% filter(str_detect(source_file, "^final_selected_test_"))
val_df  <- diamond_all %>% filter(str_detect(source_file, "^final_selected_val_"))



test_df_list <- test_df %>%
  mutate(similarity = str_extract(source_file, "(?<=test_)\\d+"))

# split into a list of dataframes, one per similarity
test_df_list <- split(test_df_list, test_df_list$similarity)

head(test_df_list[["100"]])


val_df_list <- val_df %>%
  mutate(similarity = str_extract(source_file, "(?<=val_)\\d+"))

# split into a list of dataframes, one per similarity
val_df_list <- split(val_df_list, val_df_list$similarity)

head(val_df_list[["100"]])



# Specify the path to your folder containing the .csv files
folder_path <- "../../BGF_clustering/train_test_val_final/test/"

# List all .csv files in the directory
csv_files <- list.files(folder_path, pattern = "\\.csv$", full.names = TRUE)

# Read each .csv file into a dataframe and store them in a list
csv_data_list <- lapply(csv_files, read.csv)

# Extract similarity score from filenames and set it as the name for each dataframe
similarity_labels <- str_extract(basename(csv_files), "\\d+")
names(csv_data_list) <- similarity_labels

# View the first few rows of one of the dataframes (e.g., for similarity level "90")
head(csv_data_list[["90"]])


# Merge per similarity

merged_test_list <- lapply(names(test_df_list), function(sim) {
  test_df <- test_df_list[[sim]]
  csv_df  <- csv_data_list[[sim]]
  
  # Rename csv to avoid clashes
  csv_df <- csv_df %>%
    rename(query_id = id,
           csv_subject_gene = gene,
           csv_subject_cycle = cycle)
  
  # Join
  merged <- csv_df %>%
    left_join(test_df, by = "query_id")
  
  # Mark unassigned subjects
  merged <- merged %>%
    mutate(
      subject_gene  = ifelse(is.na(subject_gene), "unassigned", subject_gene),
      subject_cycle = ifelse(is.na(subject_cycle), "unassigned", subject_cycle),
      query_gene    = ifelse(subject_gene == "unassigned", csv_subject_gene, query_gene),
      query_cycle   = ifelse(subject_gene == "unassigned", csv_subject_cycle, query_cycle)
    ) %>%
    select(-csv_subject_gene, -csv_subject_cycle)  # drop helper cols
  
  return(merged)
})

names(merged_test_list) <- names(test_df_list)








folder_path <- "../../BGF_clustering/train_test_val_final/validation/"

# List all .csv files in the directory
csv_files <- list.files(folder_path, pattern = "\\.csv$", full.names = TRUE)

# Read each .csv file into a dataframe and store them in a list
csv_data_list <- lapply(csv_files, read.csv)

# Extract similarity score from filenames and set it as the name for each dataframe
similarity_labels <- str_extract(basename(csv_files), "\\d+")
names(csv_data_list) <- similarity_labels

# View the first few rows of one of the dataframes (e.g., for similarity level "90")
head(csv_data_list[["90"]])


# Merge per similarity
library(dplyr)

merged_val_list <- lapply(names(val_df_list), function(sim) {
  val_df <- val_df_list[[sim]]
  csv_df  <- csv_data_list[[sim]]
  
  # Rename csv to avoid clashes
  csv_df <- csv_df %>%
    rename(query_id = id,
           csv_subject_gene = gene,
           csv_subject_cycle = cycle)
  
  # Join
  merged <- csv_df %>%
    left_join(val_df, by = "query_id")
  
  # Mark unassigned queries
  merged <- merged %>%
    mutate(
      query_gene  = ifelse(is.na(query_gene), "unassigned", query_gene),
      query_cycle = ifelse(is.na(query_cycle), "unassigned", query_cycle),
      subject_gene  = ifelse(query_gene == "unassigned", csv_subject_gene, subject_gene),
      subject_cycle = ifelse(query_gene == "unassigned", csv_subject_cycle, subject_cycle)
    ) %>%
    select(-csv_subject_gene, -csv_subject_cycle)  # drop helper cols
  
  return(merged)
})

names(merged_val_list) <- names(val_df_list)



filter_sequences <- function(df_list, max_len = 1024) {
  lapply(names(df_list), function(name) {
    df <- df_list[[name]]
    if ("sequence" %in% names(df)) {
      # Ensure character type
      df$sequence <- as.character(df$sequence)
      
      # Remove whitespace/newlines so length matches Python's len()
      df$sequence <- gsub("\\s+", "", df$sequence)
      
      # Count before filtering
      total <- nrow(df)
      
      # Filter
      df <- df[nchar(df$sequence, type = "chars") <= max_len, ]
      
      # Count after filtering
      kept <- nrow(df)
      removed <- total - kept
      
      # Print a clean summary line
      message(sprintf("Dataset '%s': kept %d of %d (removed %d)", name, kept, total, removed))
    } else {
      message(sprintf("Dataset '%s': no 'sequence' column, skipped", name))
    }
    df
  })
}

merged_val_list  <- filter_sequences(merged_val_list)
merged_test_list <- filter_sequences(merged_test_list)






test_df_selected_list <- lapply(merged_test_list, function(df) {
  df %>%
    select(query_id, subject_id, query_cycle, subject_cycle, source_file) %>%
    distinct()
})



val_df_selected_list <- lapply(merged_val_list, function(df) {
  df %>%
    select(query_id, subject_id, query_cycle, subject_cycle, source_file) %>%
    distinct()
})








saveRDS(test_df_list, "../../diamond_run_val_test_anti_split/val_test_processed/test_df_list.rds")
saveRDS(val_df_list, "../../diamond_run_val_test_anti_split/val_test_processed/val_df_list.rds")


saveRDS(merged_test_list, "../../diamond_run_val_test_anti_split/val_test_processed/merged_test_list.rds")
saveRDS(merged_val_list, "../../diamond_run_val_test_anti_split/val_test_processed/merged_val_list.rds")


names(val_df_selected_list) <- names(val_df_list)
names(test_df_selected_list) <- names(test_df_list)



head(test_df_selected_list[["100"]])
head(val_df_selected_list[["100"]])


library(data.table)

# For val list
dups_val_list <- lapply(names(val_df_selected_list), function(sim) {
  dt <- as.data.table(val_df_selected_list[[sim]])
  dt[, .N, by = .(source_file, query_id)][N > 1][, similarity := sim]
})

# For test list
dups_test_list <- lapply(names(test_df_selected_list), function(sim) {
  dt <- as.data.table(test_df_selected_list[[sim]])
  dt[, .N, by = .(source_file, query_id)][N > 1][, similarity := sim]
})




# Directory for output
out_dir <- "../../diamond_run_val_test_anti_split/val_test_processed"
dir.create(out_dir, showWarnings = FALSE)

# Write VAL dfs
lapply(names(val_df_selected_list), function(sim) {
  out_file <- file.path(out_dir, paste0("diamond_val_", sim, ".csv"))
  write.csv(val_df_selected_list[[sim]], out_file, row.names = FALSE)
})

# Write TEST dfs
lapply(names(test_df_selected_list), function(sim) {
  out_file <- file.path(out_dir, paste0("diamond_test_", sim, ".csv"))
  write.csv(test_df_selected_list[[sim]], out_file, row.names = FALSE)
})

