library(tidyverse)
library(ggplot2)
library(Biostrings)
library(stringr)
library(phylotools)


setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

metadata <- read_table("../../NCyc/data/id2gene.map", col_names = F) 

colnames(metadata) <- c("id", "gene")
metadata$database <- NA

metadata <- filter(metadata, is.na(id) == FALSE | is.na(gene) == FALSE)

write.csv(metadata, "../../cycdb_csv/metadata/metadata_filtered_ncyc.csv", row.names = F)


df <- read.fasta("../../NCyc/data/NCycDB_bracketrm.faa")

colnames(df) <- c("seq_name", "sequence")

write.csv(df, "../../cycdb_csv/sequences/ncyc_bracketrm.csv", row.names = F)


df$seq_name











