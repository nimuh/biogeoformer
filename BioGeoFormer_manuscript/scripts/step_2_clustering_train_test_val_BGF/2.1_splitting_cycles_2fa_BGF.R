library(tidyverse)
library(ggplot2)
library(Biostrings)
library(stringr)
library(phylotools)
library(dplyr)


setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

df <- read.csv("../../BioGeoFormer_db/BioGeoFormer_db.csv")

check_gene_cycle_overlap <- function(df) {
  # Collapse to distinct gene–cycle pairs in case there are duplicate rows
  gene_cycle_unique <- df %>%
    distinct(gene, cycle)
  
  # Count how many distinct cycles each gene appears in
  gene_cycle_counts <- gene_cycle_unique %>%
    group_by(gene) %>%
    summarise(n_cycles = n_distinct(cycle),
              cycles = paste(sort(unique(cycle)), collapse = ", ")) %>%
    filter(n_cycles > 1)
  
  if (nrow(gene_cycle_counts) == 0) {
    cat("no genes appear in more than one cycle.\n")
    return(invisible(NULL))
  } else {
    cat("Found genes that occur in multiple cycles:\n")
    print(gene_cycle_counts)
    return(gene_cycle_counts)
  }
}

check_gene_cycle_overlap(df)


dups_df<- df %>%
  group_by(id) %>%
  filter(n() > 1) %>%
  arrange(id)

print(dups_df)


split_data <- split(df, df$cycle)

split_data_selected <- lapply(split_data, function(x) x[, c("id", "sequence")])

split_data_selected <- lapply(split_data_selected, function(x) {
  colnames(x) <- c("seq.name", "seq.text")
  return(x)
})

row_counts <- sapply(split_data_selected, nrow)

median(row_counts)



row_counts <- sapply(split_data_selected, nrow)

median(row_counts)

setwd("../../BGF_clustering/cycle_division_split/")

for (category_name in names(split_data_selected)) {
  assign(paste("combined100", category_name, sep = ""), split_data_selected[[category_name]])
}






for (category_name in names(split_data_selected)) {
  dat2fasta(split_data_selected[[category_name]], paste0("combined100_", category_name, ".faa"))
}













