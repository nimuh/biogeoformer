setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()


combined <- read.csv("../../BioGeoFormer_db/BioGeoFormer_db.csv")




load_aug26_datasets <- function(base_dir = "../../BGF_clustering/train_test_val_final") {
  # Define subfolders of interest
  splits <- c("train", "validation", "test")
  
  # Initialize output list
  datasets <- list(train = list(), validation = list(), test = list())
  
  for (split in splits) {
    split_dir <- file.path(base_dir, split)
    
    # List CSVs inside the subfolder
    all_files <- list.files(split_dir, pattern = "\\.csv$", full.names = TRUE)
    
    if (length(all_files) == 0) {
      warning("No CSV files found in ", split_dir)
      next
    }
    
    for (f in all_files) {
      fname <- basename(f)
      # Extract similarity number from filename
      sim <- sub(".*_(\\d+)\\.csv$", "\\1", fname)
      
      message("Reading: ", f)
      df <- read.csv(f, stringsAsFactors = FALSE)
      
      # Map split folder to simple name (train/val/test)
      split_name <- sub("_aug26", "", split)
      datasets[[split_name]][[sim]] <- df
    }
  }
  
  return(datasets)
}

# Example usage
datasets <- load_aug26_datasets()

# Check loaded data
names(datasets$test)   # similarity levels available in test
names(datasets$train)  # similarity levels available in train
names(datasets$validation)    # similarity levels available in val






combine_by_similarity <- function(datasets) {
  # Get all similarity levels across train/val/test
  all_sims <- unique(unlist(lapply(datasets, names)))
  
  combined <- list()
  
  for (sim in all_sims) {
    dfs <- list()
    
    if (sim %in% names(datasets$train)) {
      tmp <- datasets$train[[sim]]
      tmp$split <- "train"
      dfs <- c(dfs, list(tmp))
    }
    
    if (sim %in% names(datasets$validation)) {
      tmp <- datasets$validation[[sim]]
      tmp$split <- "validation"
      dfs <- c(dfs, list(tmp))
    }
    
    if (sim %in% names(datasets$test)) {
      tmp <- datasets$test[[sim]]
      tmp$split <- "test"
      dfs <- c(dfs, list(tmp))
    }
    
    # Bind them together
    combined[[sim]] <- do.call(rbind, dfs)
  }
  
  return(combined)
}

# Example usage
combined_datasets <- combine_by_similarity(datasets)

# Check results
names(combined_datasets)   # should show "20", "30", "40", ...
table(combined_datasets[["20"]]$split)  # see counts from train/val/test at similarity 20





library(dplyr)

anti_merge_each_split <- function(combined_df, combined_datasets) {
  result <- list()
  
  for (sim in names(combined_datasets)) {
    ids_in_split <- combined_datasets[[sim]]$id
    
    # Anti-join: keep rows in combined_df that are NOT in this similarity split
    df_filtered <- combined_df %>%
      filter(!id %in% ids_in_split)
    
    result[[sim]] <- df_filtered
  }
  
  return(result)
}

# Example usage:
# combined = your big dataframe with all sequences
# combined_datasets = from combine_by_similarity(datasets)

anti_splits <- anti_merge_each_split(combined, combined_datasets)

# Inspect
names(anti_splits)            # similarity levels available
nrow(anti_splits[["20"]])     # number of unique rows from combined not in split 20



library(dplyr)

check_anti_merges <- function(combined_datasets, anti_splits) {
  result <- list()
  
  for (sim in names(combined_datasets)) {
    split_df <- combined_datasets[[sim]]
    anti_df  <- anti_splits[[sim]]
    
    # Merge (bind) the two together
    merged_df <- bind_rows(
      split_df %>% mutate(source = paste0("split_", sim)),
      anti_df  %>% mutate(source = paste0("anti_", sim))
    )
    
    # Sanity check: no id should appear in both
    dup_ids <- merged_df %>%
      group_by(id) %>%
      filter(n() > 1) %>%
      pull(id) %>%
      unique()
    
    if (length(dup_ids) > 0) {
      message("⚠️ Overlap found at similarity ", sim, " for ids: ", paste(dup_ids, collapse = ", "))
    } else {
      message("✅ Anti-merge confirmed for similarity ", sim)
    }
    
    result[[sim]] <- merged_df
  }
  
  return(result)
}

# Example usage
merged_checks <- check_anti_merges(combined_datasets, anti_splits)

# Inspect
names(merged_checks)              # similarity splits
table(merged_checks[["20"]]$source)  # counts from split vs anti






library(dplyr)

check_duplicates_in_antis <- function(anti_splits) {
  dup_report <- list()
  
  for (sim in names(anti_splits)) {
    df <- anti_splits[[sim]]
    
    dup_ids <- df %>%
      count(id) %>%
      filter(n > 1)
    
    if (nrow(dup_ids) > 0) {
      message("⚠️ Duplicates found in anti-split ", sim, ": ", nrow(dup_ids), " duplicate ids")
      dup_report[[sim]] <- dup_ids
    } else {
      message("✅ No duplicates in anti-split ", sim)
    }
  }
  
  return(dup_report)
}

# Example usage:
dup_report <- check_duplicates_in_antis(anti_splits)

# If empty, no duplicates
dup_report


write_anti_splits <- function(anti_splits, out_dir = "anti_splits_output") {
  # Create output directory if it doesn't exist
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
  
  for (sim in names(anti_splits)) {
    df <- anti_splits[[sim]]
    
    # --- Write CSV ---
    csv_file <- file.path(out_dir, paste0("anti_split_", sim, ".csv"))
    write.csv(df, csv_file, row.names = FALSE)
    
    # --- Write FASTA ---
    fasta_file <- file.path(out_dir, paste0("anti_split_", sim, ".fasta"))
    con <- file(fasta_file, "w")
    for (i in seq_len(nrow(df))) {
      writeLines(paste0(">", df$id[i]), con)
      writeLines(df$sequence[i], con)
    }
    close(con)
    
    message("✅ Wrote ", csv_file, " and ", fasta_file)
  }
}


# Save to a custom folder
write_anti_splits(anti_splits, out_dir = "../../BGF_clustering/anti_splits")





















