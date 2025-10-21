library(tidyverse)
library(Biostrings)

# Function to process a CSV file and write it as a FASTA file
process_csv_to_fasta <- function(file_path, output_folder) {
  # Read the CSV file
  df <- read.csv(file_path, stringsAsFactors = FALSE)
  
  # Extract the base filename (without extension) to use in FASTA file naming
  base_filename <- tools::file_path_sans_ext(basename(file_path))
  
  # Function to write the dataframe as a FASTA file
  write_fasta_protein <- function(df, filename) {
    # Create an AAStringSet object from the 'sequence' column (protein sequences)
    protein_sequences <- AAStringSet(df$sequence)
    
    # Set the names of the sequences using the 'id' column
    names(protein_sequences) <- df$id
    
    # Write the protein sequences to a FASTA file
    writeXStringSet(protein_sequences, filepath = filename)
  }
  
  # Create the output FASTA filename
  output_file <- file.path(output_folder, paste0(base_filename, ".fasta"))
  
  # Write the dataframe as a FASTA file
  write_fasta_protein(df, output_file)
  
  # Confirmation message
  cat("FASTA file has been written to:", output_file, "\n")
}

# Function to process all CSV files in a folder
process_all_csv_in_folder <- function(folder_path, output_folder) {
  # Get the list of CSV files in the specified folder
  file_list <- list.files(path = folder_path, pattern = "\\.csv$", full.names = TRUE)
  
  # Loop through each file and process it
  for (file in file_list) {
    process_csv_to_fasta(file, output_folder)
  }
}

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

# Specify your input folder and output folder
input_folder <- "../../BGF_clustering/train_test_val_final/train"
output_folder <- "../../BGF_clustering/train_test_val_final/train_fasta"

# Process all CSV files in the folder
process_all_csv_in_folder(input_folder, output_folder)
