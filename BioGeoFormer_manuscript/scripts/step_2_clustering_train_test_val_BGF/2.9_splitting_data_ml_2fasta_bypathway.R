library(tidyverse)
library(phylotools)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

# Set working directory to where the selected_*.csv files are located
setwd("../../BGF_clustering/train_test_val_final/train_test_val/")  # Adjust as needed

# Output directory for FASTA files
output_dir <- "../../train_test_val_fasta_bypathway/"
dir.create(output_dir, showWarnings = FALSE)

# Define dataset parts and similarity levels
similarities <- c("20", "30", "40", "50", "60", "70", "80", "90", "100")
set_types <- c("train", "val", "test")

# Sanitize cycle names for safe filenames
sanitize_name <- function(name) {
  gsub("[^a-zA-Z0-9_\\-]", "_", name)
}

# Loop through all selected_*.csv files
for (set_type in set_types) {
  for (sim in similarities) {
    file_name <- paste0("final_selected_", set_type, "_", sim, ".csv")
    
    if (!file.exists(file_name)) {
      cat("Skipping", file_name, "- file not found.\n")
      next
    }
    
    df <- read_csv(file_name)
    
    if (!all(c("id", "cycle", "sequence") %in% colnames(df))) {
      cat("Skipping", file_name, "- missing required columns.\n")
      next
    }
    
    # Split by cycle
    split_data <- split(df, df$cycle)
    
    for (cycle_name in names(split_data)) {
      sub_df <- split_data[[cycle_name]] %>%
        select(seq.name = id, seq.text = sequence)
      
      safe_cycle <- sanitize_name(cycle_name)
      fasta_filename <- paste0("selected_", set_type, "_", sim, "_", safe_cycle, ".fasta")
      fasta_path <- file.path(output_dir, fasta_filename)
      
      dat2fasta(sub_df, outfile = fasta_path)
      cat("✅ Wrote:", fasta_filename, "with", nrow(sub_df), "sequences\n")
    }
  }
}
