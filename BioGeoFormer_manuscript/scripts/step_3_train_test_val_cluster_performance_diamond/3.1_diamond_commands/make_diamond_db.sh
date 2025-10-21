#!/bin/bash

# Path to the folder containing fasta files
fasta_folder="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/cycle_split_check"

# Loop through all fasta files containing "train" in the filename
for fasta_file in "$fasta_folder"/*train*.fasta; do
  # Extract the base name without .fasta extension
  base_name=$(basename "$fasta_file" .fasta)

  # Echo the DIAMOND makedb command instead of running it
  echo "diamond makedb --in $fasta_file --db ${fasta_folder}/${base_name}_db"
done
