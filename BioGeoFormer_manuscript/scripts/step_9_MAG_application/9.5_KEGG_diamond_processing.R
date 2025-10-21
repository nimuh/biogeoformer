library(dplyr)


setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

### Reading the full prodigal .csv in and labeling the columns

# Define the path to your .csv file
file_path <- "../../cold_seep_MAG_application/mags_processed/MAGs_combined_prodigal.csv"

# Read the CSV file into a dataframe with specific column names
full_data <- read.csv(file_path, header = FALSE, stringsAsFactors = FALSE,
                 col.names = c("Sequence_ID", "Start", "End", "Strand", 
                               "ID", "Partial", "Start_Type", 
                               "RBS_Motif", "RBS_Spacer", 
                               "GC_Content", "Sequence"))


## Reading the kegg annotation table in 
kegg_annotation <- read.table("MAGS_annotated_kegg.tsv", header = FALSE, sep = "\t")


colnames(kegg_annotation) <- c("ID", "Gene", "Percent_Identity", "Alignment_Length", "Mismatches", 
                    "Gap_Openings", "Query_Start", "Query_End", "Subject_Start", 
                    "Subject_End", "E_value", "Bit_Score")


head(kegg_annotation)

filtered_kegg_annotation <- kegg_annotation %>%
  filter(Percent_Identity >= 50,
         E_value <= 1e-5,
         Bit_Score >= 50)



combined_data <- full_join(full_data, filtered_kegg_annotation, by = c("Sequence_ID" = "ID"))


combined_data <- combined_data %>%
  mutate(Gene = if_else(is.na(Gene), "Unassigned", Gene))


### Reading KO mapping dataframe (will not run unless you are able to point to Prokaryotes.dat from KEGG)

ko_mapper <- read.table("prokaryotes.dat", header = FALSE, sep = "\t", fill = TRUE)

colnames(ko_mapper) <- c("ID", "KO", "Length", "Domains")


combined_data <- left_join(combined_data, ko_mapper, by = c("Gene" = "ID"))


#will not run unless you have this dataset from the KEGG database
ko_md <- read.table("ko_module.list", header = FALSE, sep = "\t", stringsAsFactors = FALSE)



colnames(ko_md) <- c("KO", "MD")


ko_md$KO <- sub("^ko:", "", ko_md$KO)
ko_md$MD <- sub("^md:", "", ko_md$MD)



ko_md_aggregated <- ko_md %>%
  group_by(KO) %>%
  summarize(Modules = paste(unique(MD), collapse = ", "))


combined_data <- left_join(combined_data, ko_md_aggregated, by = c("KO"))



# Use str_extract to capture only the prefix and number after the first underscore
library(stringr)

# Extract the pattern `prefix_number`
combined_data$new_column <- str_extract(combined_data$Sequence_ID, "^[^_]+_[0-9]+")

# Reorder columns to place the new column first
combined_data <- combined_data[, c("new_column", setdiff(names(combined_data), "new_column"))]

# Rename the new column as desired, e.g., "CSMAG_ID"
colnames(combined_data)[1] <- "CSMAG_ID"

# View the updated dataframe
head(combined_data)


anyDuplicated(colnames(combined_data))

colnames(combined_data) <- make.names(colnames(combined_data), unique = TRUE)


combined_data <- combined_data %>%
  mutate(contig_ID = str_extract(Sequence_ID, "k\\d+_\\d+"))


combined_data <- select(combined_data, c("CSMAG_ID", "Sequence_ID", "contig_ID", "Start", "End", "Strand", "ID", "Partial", 
                           "Start_Type", "RBS_Motif", "RBS_Spacer", "GC_Content", "Sequence", "Gene", "Percent_Identity",
                        "Alignment_Length", "Mismatches", "Gap_Openings", "Query_Start", "Query_End", "Subject_Start",
                        "Subject_End", "E_value", "Bit_Score", "KO", "Length", "Domains", "Modules"))

write.csv(combined_data, "../../cold_seep_MAG_application/MAGS_annotated_50.csv", row.names = FALSE)



length(unique(combined_data$contig_ID))











