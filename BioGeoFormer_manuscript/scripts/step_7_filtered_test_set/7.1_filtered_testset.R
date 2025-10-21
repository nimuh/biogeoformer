library(dplyr)
library(purrr)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()


merged_test_list <- readRDS("../../diamond_run_val_test_anti_split/val_test_processed/merged_test_list.rds")

new_names <- c("100", "20", "30", "40", "50", "60", "70", "80", "90")
names(merged_test_list) <- new_names


merged_test_list <- merged_test_list[names(merged_test_list) != "100"]




# Path to HMM outputs
hmm_path <- "../../hmm_run_val_test_anti_split/test_processed_hmm/"


# Which similarity splits exist
similarities <- c(20, 30, 40, 50, 60, 70, 80, 90)

# Read all HMM files into a list
hmm_list <- lapply(similarities, function(sim) {
  file <- file.path(hmm_path, paste0("merged_data_", sim, ".csv"))
  df <- read.csv(file)
  df$Similarity <- sim
  df
})
names(hmm_list) <- as.character(similarities)

# Merge with filtered_test_dfs by similarity
merged_results <- lapply(names(merged_test_list), function(sim) {
  test_df <- merged_test_list[[sim]]
  hmm_df <- hmm_list[[sim]]
  
  merged_df <- test_df %>%
    left_join(hmm_df, by = c("query_id" = "target_name"))
  
  merged_df
})
names(merged_results) <- names(merged_test_list)

# Example: inspect 40% similarity merged
head(merged_results[["40"]])


library(dplyr)

# Path to Cycformer annotations
cycformer_path <- "../../BGF_run_val_test_anti_split/test/"

# Available similarities for Cycformer
cycformer_sims <- c(20, 30, 40, 50, 60, 70, 80, 90)

# Read annotation files into a list
cycformer_list <- lapply(cycformer_sims, function(sim) {
  file <- file.path(cycformer_path, paste0("test_", sim, "_annotations.csv"))
  df <- read.csv(file)
  df$Similarity <- sim
  df
})
names(cycformer_list) <- as.character(cycformer_sims)

# Merge Cycformer annotations with merged_results
final_results <- lapply(names(merged_results), function(sim) {
  merged_df <- merged_results[[sim]]
  
  if (sim %in% names(cycformer_list)) {
    cycformer_df <- cycformer_list[[sim]]
    
    # Merge by IDs (cycformer) vs query_id (merged)
    merged_df <- merged_df %>%
      left_join(cycformer_df, by = c("query_id" = "IDs"))
  }
  
  merged_df
})
names(final_results) <- names(merged_results)

# Example: look at 60% similarity merged with cycformer annotations
head(final_results[["60"]])



library(dplyr)

select_relevant <- function(df) {
  # Add missing cols if not present
  for (col in c("predicted_cycle", "prediction", "cycle", "confidence")) {
    if (!col %in% names(df)) {
      df[[col]] <- NA
    }
  }
  
  df %>%
    select(query_id, percent_identity, query_cycle, subject_cycle, 
           predicted_cycle, prediction, confidence, cycle)
}


# Apply across your list of dfs (e.g., final_results_flipped)
final_selected_list <- lapply(final_results, select_relevant)

# Example: check structure of one
str(final_selected_list[["40"]])


# Remove rows where prediction is NA
final_selected_list <- lapply(final_selected_list, function(df) {
  df %>% filter(!is.na(prediction))
})


# Remove rows where prediction is NA
final_selected_list <- lapply(final_selected_list, function(df) {
  df %>% filter(!is.na(prediction))
})







# Function: filter by similarity and include unassigned as <20%
make_filtered_dfs <- function(merged_test_list) {
  filtered_list <- lapply(names(merged_test_list), function(split_name) {
    df <- merged_test_list[[split_name]]
    split_val <- as.numeric(split_name)
    
    # Apply filtering scheme
    filtered <- df %>%
      filter(percent_identity <= split_val | subject_cycle == "unassigned") %>%
      mutate(Similarity = split_val)
    
    return(filtered)
  })
  
  names(filtered_list) <- names(merged_test_list)
  return(filtered_list)
}

# Example usage
final_selected_list_filtered <- make_filtered_dfs(final_selected_list)

# Inspect the 40% split
head(final_selected_list_filtered[["40"]])












#Define output path
out_path <- "../../filtered_test_set/split_test_diamond_hmm_bgf"
dir.create(out_path, showWarnings = FALSE)

# Define models and their column subsets
model_cols <- list(
  DIAMOND = c("query_id", "percent_identity", "query_cycle", "subject_cycle"),
  HMM     = c("query_id", "predicted_cycle", "cycle"),
  BGF     = c("query_id", "prediction", "confidence", "cycle")
)

# Loop over each similarity split in final_selected_list
walk(names(final_selected_list_filtered), function(sim) {
  df <- final_selected_list_filtered[[sim]]
  
  # DIAMOND
  if (any(model_cols$DIAMOND %in% colnames(df))) {
    diamond_out <- df %>% select(intersect(model_cols$DIAMOND, colnames(df)))
    outfile <- file.path(out_path, paste0("diamond_", sim, ".csv"))
    write.csv(diamond_out, outfile, row.names = FALSE)
    message("Wrote: ", outfile, " (", nrow(diamond_out), " rows)")
  }
  
  # HMM
  if (any(model_cols$HMM %in% colnames(df))) {
    hmm_out <- df %>% select(intersect(model_cols$HMM, colnames(df)))
    outfile <- file.path(out_path, paste0("hmm_", sim, ".csv"))
    write.csv(hmm_out, outfile, row.names = FALSE)
    message("Wrote: ", outfile, " (", nrow(hmm_out), " rows)")
  }
  
  # BGF
  if (any(model_cols$BGF %in% colnames(df))) {
    bgf_out <- df %>% select(intersect(model_cols$BGF, colnames(df)))
    outfile <- file.path(out_path, paste0("bgf_", sim, ".csv"))
    write.csv(bgf_out, outfile, row.names = FALSE)
    message("Wrote: ", outfile, " (", nrow(bgf_out), " rows)")
  }
})



all_splits_list <- final_selected_list   # or merged_test_list

# Function: filter by similarity cutoff (always include unassigned)
filter_by_similarity <- function(df, sim_val) {
  df %>% filter(percent_identity <= sim_val | subject_cycle == "unassigned")
}


# Define similarity cutoffs
similarities <- c(20, 30, 40, 50, 60, 70, 80, 90)

# Output base directory
out_base <- "../../filtered_test_set/test_filtered_all"
dir.create(out_base, showWarnings = FALSE)

# Loop over each similarity split in your list
walk(names(all_splits_list), function(split_name) {
  df_split <- all_splits_list[[split_name]]
  
  # Create subdirectory for this split
  split_dir <- file.path(out_base, paste0("split_", split_name))
  dir.create(split_dir, showWarnings = FALSE)
  
  # Apply filtering across cutoffs
  filtered_list <- map(similarities, ~filter_by_similarity(df_split, .x))
  names(filtered_list) <- as.character(similarities)
  
  # Write each filtered df to CSV
  walk(names(filtered_list), function(sim) {
    out_file <- file.path(split_dir, paste0("test", split_name, "_filtered_", sim, ".csv"))
    write.csv(filtered_list[[sim]], out_file, row.names = FALSE)
    message("Wrote: ", out_file, " (", nrow(filtered_list[[sim]]), " rows)")
  })
})











