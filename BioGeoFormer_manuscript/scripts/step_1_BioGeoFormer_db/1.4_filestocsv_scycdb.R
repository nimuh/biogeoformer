library(tidyverse)
library(ggplot2)
library(Biostrings)
library(stringr)
library(phylotools)


setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

metadata <- read_table("../../SCycDb/id2gene.map.2021", col_names = F) 

colnames(metadata) <- c("id", "gene", "database")


metadata <- filter(metadata, is.na(database) == FALSE | is.na(id) == FALSE | is.na(gene) == FALSE)

write.csv(metadata, "../../cycdb_csv/metadata/metadata_filtered_scycdb.csv", row.names = F)



df <- read.fasta("../../SCycDB/SCycDB_bracketrm.faa")

colnames(df) <- c("seq_name", "sequence")

write.csv(df, "../../cycdb_csv/sequences/scycdb_bracketrm.csv", row.names = F)


df$seq_name



