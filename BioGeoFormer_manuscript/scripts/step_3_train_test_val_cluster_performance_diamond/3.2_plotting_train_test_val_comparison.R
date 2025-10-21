library(ggplot2)
library(viridis)


setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

# List all the .daa files
files <- list.files(path = "../../BGF_clustering/comparing_train_test_val_diamond/", pattern = "*.daa", full.names = TRUE)

# Function to extract metadata from the filename
extract_metadata <- function(filename) {
  # Remove path and extension
  file <- basename(filename)
  file <- sub("\\.daa$", "", file)
  
  # Extract dataset type, similarity, and cycle
  parts <- strsplit(file, "_")[[1]]
  dataset_type <- parts[2]  # test or val
  similarity <- as.numeric(parts[3])  # sequence similarity level (e.g., 40)
  biogeo_cycle <- paste(parts[4:(length(parts)-1)], collapse = "_")  # biogeochemical cycle
  
  return(c(dataset_type = dataset_type, similarity = similarity, biogeo_cycle = biogeo_cycle))
}

# Initialize an empty dataframe
results <- data.frame(dataset_type = character(),
                      similarity = numeric(),
                      biogeo_cycle = character(),
                      median_similarity = numeric(),
                      stringsAsFactors = FALSE)

# Loop through each file
for (file in files) {
  # Extract metadata
  meta <- extract_metadata(file)
  
  # Check if the file is empty
  if (file.info(file)$size == 0) {
    cat("Skipping empty file:", file, "\n")
    next  # Skip to the next file
  }
  
  # Try reading the alignment file and handle errors if the file cannot be read
  align_data <- tryCatch({
    read.table(file, header = FALSE, sep = "\t")
  }, error = function(e) {
    cat("Error reading file:", file, "\n")
    return(NULL)
  })
  
  # If align_data is NULL (due to an error), skip this file
  if (is.null(align_data)) {
    next
  }
  
  # Assuming sequence similarity is in the 3rd column (adjust if necessary)
  median_similarity <- median(align_data$V3)
  
  # Add results to the dataframe
  results <- rbind(results, data.frame(
    dataset_type = meta["dataset_type"],
    similarity = as.numeric(meta["similarity"]),
    biogeo_cycle = meta["biogeo_cycle"],
    median_similarity = median_similarity
  ))
}

rownames(results) <- NULL

# Check the results
print(results, row.names = FALSE)


dups <- results[duplicated(results), ]


# Split into 'test' and 'val'
test_df <- subset(results, dataset_type == "test")
val_df <- subset(results, dataset_type == "val")


# Plot for 'test' dataset
test_plot <- ggplot(test_df, aes(x = similarity, y = median_similarity, color = biogeo_cycle, group = biogeo_cycle)) +
  geom_point() +  # Add dots for each datapoint
  geom_line() +   # Connect the dots with a line
  labs(title = "Test Dataset", x = "Sequence Similarity", y = "Median Sequence Similarity", color = "Biogeochemical Cycle") +
  theme_minimal() +
  theme(legend.position = "right")

# Print the test plot
print(test_plot)


test_df$median_dissimilarity <- 100 - test_df$median_similarity


write.csv(test_df, "../../BGF_clustering/comparing_train_test_val_diamond/identity_splits_test.csv")


# Plot for 'val' dataset
val_plot <- ggplot(val_df, aes(x = similarity, y = median_similarity, color = biogeo_cycle, group = biogeo_cycle)) +
  geom_point() +  # Add dots for each datapoint
  geom_line() +   # Connect the dots with a line
  labs(title = "Val Dataset", x = "Sequence Similarity", y = "Median Sequence Similarity", color = "Biogeochemical Cycle") +
  theme_minimal() +
  theme(legend.position = "right")
# Print the val plot
print(val_plot)

val_df$median_dissimilarity <- 100 - val_df$median_similarity


write.csv(val_df, "../../BGF_clustering/comparing_train_test_val_diamond/identity_splits_val.csv")

library(ggplot2)




ggplot(test_df, aes(x = factor(similarity), y = median_dissimilarity)) +
  geom_boxplot(fill = "lightblue", color = "black") +
  labs(
    title = "Median Dissimilarity between train and test sets",
    x = "Sequence Similarity",
    y = "Median Dissimilarity"
  ) +
  theme_minimal(base_size = 14)

# assuming your dataframe is called df
ggplot(val_df, aes(x = factor(similarity), y = median_dissimilarity)) +
  geom_boxplot(fill = "lightblue", color = "black") +
  labs(
    title = "Median Dissimilarity between train and validation sets",
    x = "Sequence Similarity",
    y = "Median Dissimilarity"
  ) +
  theme_minimal(base_size = 14)



library(dplyr)

df_summary <- val_df %>%
  mutate(median_dissimilarity = 100 - median_similarity) %>%
  group_by(similarity) %>%
  summarise(
    median_dissimilarity = median(median_dissimilarity, na.rm = TRUE)
  )

df_summary





# --- Leakage proportion checks (streamlined) ---------------------------

library(dplyr)

# Helper: for one file, return summary stats directly
check_file_leakage <- function(file) {
  meta <- extract_metadata(file)
  if (file.info(file)$size == 0) return(NULL)
  
  align_data <- tryCatch({
    read.table(file, header = FALSE, sep = "\t")
  }, error = function(e) NULL)
  
  if (is.null(align_data) || nrow(align_data) == 0) return(NULL)
  
  # Extract cutoff from filename metadata
  cutoff <- as.numeric(meta["similarity"])
  
  n_total <- nrow(align_data)
  n_above <- sum(align_data$V3 > cutoff, na.rm = TRUE)
  n_perfect <- sum(align_data$V3 == 100, na.rm = TRUE)
  
  data.frame(
    dataset_type   = meta["dataset_type"],
    similarity     = cutoff,
    biogeo_cycle   = meta["biogeo_cycle"],
    n_total        = n_total,
    n_above_cutoff = n_above,
    prop_above     = n_above / n_total,
    n_perfect_dups = n_perfect,
    stringsAsFactors = FALSE
  )
}

# Run the helper across all files
leakage_summary <- do.call(rbind, lapply(files, check_file_leakage))

# Save + inspect
#write.csv(leakage_summary,
#          "~/Dropbox/cycformer_data_aug26/leakage_proportions.csv",
#          row.names = FALSE)

print(head(leakage_summary))

# Plot proportion above cutoff
library(ggplot2)

ggplot(leakage_summary, aes(x = factor(similarity), y = prop_above, fill = dataset_type)) +
  geom_col(position = "dodge") +
  labs(
    title = "Proportion of sequences above cutoff (train vs split)",
    x = "Similarity split",
    y = "Proportion above cutoff"
  ) +
  theme_minimal(base_size = 14)

# Plot number of exact duplicates
ggplot(leakage_summary, aes(x = factor(similarity), y = n_perfect_dups, fill = dataset_type)) +
  geom_col(position = "dodge") +
  labs(
    title = "100% identity duplicates (train vs split)",
    x = "Similarity split",
    y = "Count of exact duplicates"
  ) +
  theme_minimal(base_size = 14)



# Add proportion of exact duplicates
leakage_summary$prop_perfect <- leakage_summary$n_perfect_dups / leakage_summary$n_total

# Plot proportion of exact duplicates
ggplot(leakage_summary, aes(x = factor(similarity), y = prop_perfect, fill = dataset_type)) +
  geom_col(position = "dodge") +
  labs(
    title = "Proportion of 100% identity duplicates (train vs split)",
    x = "Similarity split",
    y = "Proportion of duplicates"
  ) +
  theme_minimal(base_size = 14)




# Add proportions directly
leakage_summary <- leakage_summary %>%
  mutate(
    prop_above_cutoff = n_above_cutoff / n_total,
    prop_perfect_dups = n_perfect_dups / n_total
  )

# Table 1: detailed by dataset, similarity, cycle
detailed_table <- leakage_summary %>%
  select(dataset_type, similarity, biogeo_cycle,
         n_total, n_above_cutoff, prop_above_cutoff,
         n_perfect_dups, prop_perfect_dups)

print(detailed_table)

# Table 2: aggregated by dataset + similarity (ignore cycle)
agg_table <- leakage_summary %>%
  group_by(dataset_type, similarity) %>%
  summarise(
    n_total = sum(n_total),
    n_above_cutoff = sum(n_above_cutoff),
    prop_above_cutoff = n_above_cutoff / n_total,
    n_perfect_dups = sum(n_perfect_dups),
    prop_perfect_dups = n_perfect_dups / n_total,
    .groups = "drop"
  )

print(agg_table)



library(ggplot2)

# Proportion above cutoff
ggplot(agg_table, aes(x = factor(similarity), y = prop_above_cutoff, fill = dataset_type)) +
  geom_col(position = "dodge") +
  labs(
    title = "Proportion of sequences above cutoff",
    x = "Similarity split",
    y = "Proportion above cutoff"
  ) +
  theme_minimal(base_size = 14)

# Proportion exact duplicates
ggplot(agg_table, aes(x = factor(similarity), y = prop_perfect_dups, fill = dataset_type)) +
  geom_col(position = "dodge") +
  labs(
    title = "Proportion of 100% identity duplicates",
    x = "Similarity split",
    y = "Proportion of duplicates"
  ) +
  theme_minimal(base_size = 14)




