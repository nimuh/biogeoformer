library(readr)
library(stringr)

read_hmm_file <- function(file_path) {
  # Read the file as lines
  all_lines <- readLines(file_path)
  
  # Remove header (first 3 lines) and footer/comments (those starting with '#', '//' or empty)
  data_lines <- all_lines[!grepl("^#|^//|^$", all_lines)]
  data_lines <- data_lines[4:length(data_lines)]  # Skip top 3 header lines manually
  
  # Write cleaned lines to temp file
  temp_file <- tempfile()
  writeLines(data_lines, temp_file)
  
  # Use readr::read_table for space-aligned columns
  hmm_data <- read_table(temp_file, col_names = FALSE, comment = "")
  unlink(temp_file)
  
  # Assign column names (based on HMMER domtblout output)
  colnames(hmm_data)[1:19] <- c(
    "target_name", "accession", "query_name", "query_accession", 
    "E_value_full_seq", "score_full_seq", "bias_full_seq", 
    "E_value_best_domain", "score_best_domain", "bias_best_domain", 
    "exp", "reg", "clu", "ov", "env", "dom", "rep", "inc", "description"
  )
  
  # If additional columns exist, concatenate them into the description
  if (ncol(hmm_data) > 19) {
    hmm_data$description <- apply(hmm_data[, 20:ncol(hmm_data)], 1, paste, collapse = " ")
    hmm_data <- hmm_data[, 1:20]  # Drop the extra columns
  }
  
  # Extract similarity from query_name (e.g., "selected_train_90...")
  hmm_data$similarity <- str_extract(hmm_data$query_name, "\\d+")
  
  # Add file name for traceability
  hmm_data$file <- basename(file_path)
  
  return(hmm_data)
}




setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

folder_path <- "../../cold_seep_MAG_application/HMM_BGF_output/"
files <- list.files(folder_path, pattern = "\\.txt$", full.names = TRUE)

all_hmm_data <- lapply(files, read_hmm_file) %>% bind_rows()



all_hmm_data <- select(all_hmm_data, -accession, -query_accession, -X20)



filtered_hmm_data <- all_hmm_data %>%
  filter(E_value_best_domain <= 1e-5, score_best_domain >= 25) %>%
  group_by(target_name) %>%
  slice_max(score_best_domain, n = 1, with_ties = FALSE) %>%
  ungroup()


filtered_hmm_data <- filtered_hmm_data %>%
  mutate(pathway = str_remove(query_name, "^selected_train_50_")) %>%  # create cleaned column
  select(-query_name)  # remove original query_name column

write.csv(filtered_hmm_data, "../../cold_seep_MAG_application/HMM_BGF_processed/HMM_BGF_processed.csv", row.names = FALSE)






