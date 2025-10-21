library(tidyverse)
library(phylotools)


setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()


for (cycle_name in names(split_data)) {
  sub_df <- split_data[[cycle_name]] %>%
    select(seq.name = id, seq.text = sequence)
  
  safe_cycle <- sanitize_name(cycle_name)
  fasta_filename <- paste0("selected_", set_type, "_", sim, "_", safe_cycle, ".fasta")
  fasta_path <- file.path(output_dir, fasta_filename)
  
  dat2fasta(sub_df, outfile = fasta_path)
  cat("✅ Wrote:", fasta_filename, "with", nrow(sub_df), "sequences\n")
}


combined_100 <- read_csv("../../BioGeoFormer_db/BioGeoFormer_db.csv")


combined_100_selected <- select(combined_100, id, sequence)

colnames(combined_100_selected) <- c("seq.name", "seq.text")

dat2fasta(combined_100_selected, outfile = "../../BioGeoFormer_db/BioGeoFormer_db.fasta")


