library(dplyr)
library(stringr)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

# Specify the path to your folder of HMM output files
folder_path <- "../../hmm_run_val_test_anti_split/anti_split_hmm/"

# Get a list of all HMM output files in the folder
files <- list.files(folder_path, pattern = "*.tblout", full.names = TRUE)

# Function to read and clean a single HMM output file
read_hmm_file <- function(file_path) {
  hmm_data <- read.table(
    file_path,
    header = FALSE,
    sep = "",              # whitespace-separated
    fill = TRUE,           # fill short rows with NAs
    skip = 3,              # skip the HMMER header
    comment.char = "",     # don't drop comment lines automatically
    stringsAsFactors = FALSE
  )
  
  # Assign column names (HMMER .tblout has 19 fixed cols; description may contain spaces)
  colnames(hmm_data)[1:19] <- c(
    "target_name", "accession", "query_name", "query_accession", 
    "E_value_full_seq", "score_full_seq", "bias_full_seq", 
    "E_value_best_domain", "score_best_domain", "bias_best_domain", 
    "exp", "reg", "clu", "ov", "env", "dom", "rep", "inc", 
    "description"
  )
  
  # Remove footer lines (HMMER sometimes appends lines starting with "#")
  hmm_data <- hmm_data %>%
    filter(!startsWith(target_name, "#"))
  
  # Convert numeric-like columns
  num_cols <- c(
    "E_value_full_seq", "score_full_seq", "bias_full_seq", 
    "E_value_best_domain", "score_best_domain", "bias_best_domain", 
    "exp", "reg", "clu", "ov", "env", "dom", "rep", "inc"
  )
  hmm_data[num_cols] <- lapply(hmm_data[num_cols], function(x) suppressWarnings(as.numeric(x)))
  
  # Extract similarity (first number in query_name, e.g. "selected_train_90_assnitred" -> 90)
  hmm_data$similarity <- str_extract(hmm_data$query_name, "\\d+")
  
  # Add the filename for traceability
  hmm_data$file <- basename(file_path)
  
  return(hmm_data)
}

# Apply the function to all files and combine into one dataframe
all_hmm_data <- files %>%
  lapply(read_hmm_file) %>%
  bind_rows()

# Split the combined dataframe into a list of dataframes based on similarity
hmm_data_split <- split(all_hmm_data, all_hmm_data$similarity)

# View one of the split dataframes (e.g., for similarity level "40")
head(hmm_data_split[["40"]])
str(hmm_data_split[["40"]])




filtered_unique_hmm_data_split <- lapply(hmm_data_split, function(df) {
  df %>%
    group_by(target_name) %>%
    filter(score_best_domain == max(score_best_domain)) %>%  # keep only rows at the max
    filter(n() == 1) %>%                                     # keep only if unique
    ungroup()
})


filtered_unique_hmm_data_split <- lapply(filtered_unique_hmm_data_split, function(df) {
  df %>%
    mutate(predicted_cycle = sub("^.*?_\\d+_(.*)$", "\\1", query_name))
})




library(ggplot2)


ggplot(filtered_unique_hmm_data_split[["90"]], aes(x = score_best_domain)) +
  geom_histogram(binwidth = 50, color = "black", fill = "skyblue") +
  labs(title = "Histogram of score_best_domain",
       x = "score_best_domain",
       y = "Frequency") +
  theme_minimal()



selected_hmm_data_split <- lapply(filtered_unique_hmm_data_split, function(df) {
  df %>% select(target_name, predicted_cycle)
})


dups_within <- lapply(selected_hmm_data_split, function(df) {
  df %>%
    group_by(target_name) %>%
    filter(n() > 1) %>%        # keep only duplicated target_names
    ungroup()
})


library(stringr)

# Specify the path to your folder containing the .csv files
folder_path <- "../../BGF_clustering/anti_splits/"

# List all .csv files in the directory
csv_files <- list.files(folder_path, pattern = "\\.csv$", full.names = TRUE)

# Read each .csv file into a dataframe and store them in a list
csv_data_list <- lapply(csv_files, read.csv)

# Extract similarity score from filenames and set it as the name for each dataframe
similarity_labels <- str_extract(basename(csv_files), "\\d+")
names(csv_data_list) <- similarity_labels

# View the first few rows of one of the dataframes (e.g., for similarity level "90")
head(csv_data_list[["90"]])



library(dplyr)

# Merge each pair of dataframes from selected_hmm_data_split and csv_data_list
merged_data_list <- lapply(names(selected_hmm_data_split), function(similarity) {
  hmm_df <- selected_hmm_data_split[[similarity]]
  csv_df <- csv_data_list[[similarity]]
  
  # Perform a full join on target_name and id
  full_join(hmm_df, csv_df, by = c("target_name" = "id"))
})

# Name the merged data list by similarity levels
names(merged_data_list) <- names(selected_hmm_data_split)

# View the first few rows of the merged dataframe for a specific similarity level (e.g., "90")
head(merged_data_list[["90"]])


merged_data_list <- lapply(merged_data_list, function(df) {
  df$predicted_cycle[is.na(df$predicted_cycle)] <- "unassigned"
  return(df)
})




output_dir <- "../../hmm_run_val_test_anti_split/anti_split_processed_hmm/"

# Write each dataframe in merged_data_list to a .csv file
lapply(names(merged_data_list), function(similarity) {
  # Define the filename for each similarity level
  file_name <- paste0(output_dir, "/merged_data_", similarity, ".csv")
  
  # Write the dataframe to a .csv file
  write.csv(merged_data_list[[similarity]], file_name, row.names = FALSE)
})


