#!/bin/bash

# Define the folder with the fasta files
input_folder="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/cycle_split_check"

# Define the output folder
output_folder="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/cycle_split_check/famsa_alignments"

# Create the output folder if it doesn't exist
mkdir -p "$output_folder"

# Loop through all .fasta files containing "train" in their name
for file in "$input_folder"/*train*.fasta; do
  # Extract the base name without the .fasta extension
  base_name=$(basename "${file%.fasta}")
  
  # Echo the famsa command to be used with parallel
  echo "famsa \"$file\" \"$output_folder/${base_name}.aln\""
done
