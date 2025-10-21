library(dplyr)
library(readr)
library(stringr)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

# Base directory where split_* folders live
base_dir <- "../../filtered_test_set/test_filtered_all"

# Get all split_* folders
split_dirs <- list.dirs(base_dir, recursive = FALSE, full.names = TRUE)
split_dirs <- split_dirs[grepl("split_", basename(split_dirs))]

# Initialize list
df_list <- list()

# Loop through each split_* folder
for (split_dir in split_dirs) {
  
  # Extract similarity from folder name (e.g., split_20 -> 20)
  sim <- str_extract(basename(split_dir), "\\d+")
  
  # Get all test*_filtered_*.csv files in this folder
  csv_files <- list.files(split_dir, pattern = "test.*_filtered_.*\\.csv$", full.names = TRUE)
  
  # Read them all into a list of dfs
  dfs <- lapply(csv_files, read_csv)
  
  # Give each dataframe a name based on its filename
  names(dfs) <- basename(csv_files) %>% str_remove("\\.csv$")
  
  # Store in main list with similarity as key
  df_list[[paste0("split_", sim)]] <- dfs
}

# Example access:
df_list[["split_20"]][["test20_filtered_40"]]



read_anti_split_csv <- function(folder) {
  # Get all CSV files matching merged_anti_split_*.csv
  csv_files <- list.files(folder, pattern = "^merged_anti_split_\\d+\\.csv$", full.names = TRUE)
  
  # Extract the similarity number from filenames
  sims <- str_extract(basename(csv_files), "\\d+")
  
  # Read all files into a list
  dfs <- lapply(csv_files, read_csv)
  
  # Name the list by similarity
  names(dfs) <- paste0("split_", sims)
  
  return(dfs)
}

folder <- "../../filtered_test_set/anti_split_csv/"
anti_split_list <- read_anti_split_csv(folder)

anti_split_list[["split_20"]]




read_cycformer_annotations <- function(folder) {
  csv_files <- list.files(folder, pattern = "^merged_anti_split_\\d+_annotations\\.csv$", full.names = TRUE)
  sims <- str_extract(basename(csv_files), "\\d+")
  
  dfs <- lapply(csv_files, read_csv, show_col_types = FALSE)
  names(dfs) <- sims  # name list by similarity (e.g. "20", "30")
  
  return(dfs)
}

# -------------------------
# Function 2: Merge annotations with anti_split_list
# -------------------------
merge_with_annotations <- function(anti_split_list, annot_list) {
  merged_list <- list()
  
  for (split_name in names(anti_split_list)) {
    # normalize name to numeric similarity
    sim <- str_extract(split_name, "\\d+")
    
    if (sim %in% names(annot_list)) {
      merged_df <- anti_split_list[[split_name]] %>%
        left_join(annot_list[[sim]], by = c("query_id" = "IDs"))
      
      merged_list[[sim]] <- merged_df   # store by "20", "30" instead of "split_20"
    } else {
      warning(paste("No annotation file for split:", split_name))
      merged_list[[sim]] <- anti_split_list[[split_name]]
    }
  }
  
  return(merged_list)
}

# -------------------------
# Function 3: Remove rows with NA predictions
# -------------------------
remove_na_predictions <- function(merged_list) {
  cleaned_list <- lapply(merged_list, function(df) {
    if ("prediction" %in% colnames(df)) {
      df %>% filter(!is.na(prediction))
    } else {
      df   # leave unchanged if no prediction column
    }
  })
  return(cleaned_list)
}

# -------------------------
# Function 4: Drop 100 split (works for both "100" and "split_100")
# -------------------------
drop_100_split <- function(df_list) {
  keep <- !grepl("100", names(df_list))
  df_list[keep]
}

# -------------------------
# Example full workflow
# -------------------------

annot_folder <- "../../BGF_run_val_test_anti_split/anti_split/"

# Step 1: read annotations
cycformer_annots <- read_cycformer_annotations(annot_folder)

# Step 2: drop 100 from both
cycformer_annots <- drop_100_split(cycformer_annots)
anti_split_list_no100 <- drop_100_split(anti_split_list)

# Step 3: merge
anti_split_merged <- merge_with_annotations(anti_split_list_no100, cycformer_annots)

# Step 4: clean rows with NA predictions
anti_split_cleaned <- remove_na_predictions(anti_split_merged)

# Example: check cleaned 20% split
head(anti_split_cleaned[["20"]])



# -------------------------
# Function 5: merge with HMMs
# -------------------------

# Path to HMM outputs
hmm_path <- "../../hmm_run_val_test_anti_split/anti_split_processed_hmm/"

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
merged_results <- lapply(names(anti_split_cleaned), function(sim) {
  test_df <- anti_split_cleaned[[sim]]
  hmm_df <- hmm_list[[sim]]
  
  merged_df <- test_df %>%
    left_join(hmm_df, by = c("query_id" = "target_name"))
  
  merged_df
})
names(merged_results) <- names(anti_split_cleaned)

# Example: inspect 40% similarity merged
head(merged_results[["40"]])


anti_split_with_cycle <- merged_results

head(anti_split_with_cycle[["40"]])



# Check columns for 20% split
colnames(anti_split_with_cycle[["20"]])



combined_gene_map <- read.csv("../../BioGeoFormer_db/BioGeoFormer_db.csv")




# Columns you want to keep
cols_to_keep <- c("query_id", "percent_identity", "query_cycle", "subject_cycle",
                  "predicted_cycle", "prediction", "confidence", "cycle")

# Apply to every dataframe in your list
anti_split_selected <- lapply(anti_split_with_cycle, function(df) {
  df %>% select(any_of(cols_to_keep))
})

# Example: check the 20% split
head(anti_split_selected[["20"]])








 



library(dplyr)

# Function: for each dataframe, make sub-dfs at every 10% interval
make_interval_splits <- function(df_list, intervals = seq(20, 90, 10)) {
  out_list <- list()
  
  for (split_name in names(df_list)) {
    df <- df_list[[split_name]]
    
    for (cutoff in intervals) {
      subdf <- df %>%
        filter(percent_identity <= cutoff | subject_cycle == "unassigned") %>%
        mutate(Similarity = cutoff)
      
      # Store with a combined name (e.g. "20_under30")
      out_list[[paste0(split_name, "_under", cutoff)]] <- subdf
    }
  }
  
  return(out_list)
}

# -----------------------
# Apply to anti_split_selected
# -----------------------
interval_split_list <- make_interval_splits(anti_split_selected)

# Inspect one of them
head(interval_split_list[["20_under30"]])




library(readr)
library(dplyr)

# Root folder where all split_xx folders live
root_dir <- "../../filtered_test_set/test_filtered_all/"

# Find all test CSV files recursively
test_files <- list.files(root_dir, pattern = "^test\\d+_filtered_\\d+\\.csv$", 
                         full.names = TRUE, recursive = TRUE)

# Read them into a named list
test_df <- lapply(test_files, read_csv)

# Name the list by the file stem (e.g., "test20_filtered_30")
names(test_df) <- gsub("\\.csv$", "", basename(test_files))

# Check
names(test_df)[1:10]








library(dplyr)
library(stringr)

# Function to bind interval splits with matching test dfs
bind_interval_with_test <- function(interval_splits, test_dfs) {
  out <- list()
  
  for (int_name in names(interval_splits)) {
    # Example int_name: "20_under30"
    parts <- str_split(int_name, "_under", simplify = TRUE)
    base_split <- parts[1]     # e.g. "20"
    cutoff     <- parts[2]     # e.g. "30"
    
    # Build the test_df key name: e.g. "test20_filtered_30"
    test_key <- paste0("test", base_split, "_filtered_", cutoff)
    
    if (test_key %in% names(test_dfs)) {
      cat("Merging:", int_name, "with", test_key, "\n")
      
      merged <- bind_rows(
        interval_splits[[int_name]],
        test_dfs[[test_key]]
      )
      
      out[[paste0("merged_", int_name)]] <- merged
    } else {
      cat("⚠️ No match found for", int_name, "\n")
    }
  }
  
  return(out)
}



# Example usage:
merged_interval_test <- bind_interval_with_test(interval_split_list, test_df)

# Peek at one merged df
dplyr::glimpse(merged_interval_test[["merged_20_under30"]])




library(readr)
library(stringr)

# Base output directory
outdir <- "../../filtered_test_set/final_filtered_test"

for (nm in names(merged_interval_test)) {
  # Example: nm = "merged_20_under30"
  
  # Extract the split number after "merged_" and before "_under"
  split_num <- str_match(nm, "merged_([0-9]+)_under")[,2]
  
  # Make subfolder like test_20
  subdir <- file.path(outdir, paste0("test_", split_num))
  if (!dir.exists(subdir)) dir.create(subdir, recursive = TRUE)
  
  # Build filename (keep just nm.csv)
  outfile <- file.path(subdir, paste0(nm, ".csv"))
  
  # Write out
  write_csv(merged_interval_test[[nm]], outfile)
  message("Wrote: ", outfile)
}






