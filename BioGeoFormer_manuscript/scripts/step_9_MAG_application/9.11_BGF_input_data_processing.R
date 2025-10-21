library(dplyr)
library(tidyverse)
library(Biostrings)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

setwd("../../cold_seep_MAG_application/KEGG_processed/")

MAGS <- read.csv("MAGS_annotated_50.csv")


MAGS_small <- select(MAGS, Sequence_ID, Sequence)

MAGS_small <- na.omit(MAGS_small)

MAGS_small$Sequence <- substring(MAGS_small$Sequence, 1, 1026)


# Create an AAStringSet object
seqs <- AAStringSet(MAGS_small$Sequence)

# Assign the sequence names from Sequence_ID
names(seqs) <- MAGS_small$Sequence_ID

writeXStringSet(seqs, "../../cold_seep_MAG_application/BGF_input_data/MAGS_forBGF.fasta")





