#!/bin/bash

# Set the input, output, and database directories
input_dir="/nfs5/MICRO/Thurber_Lab/jacob/MAG_processing_deepsea/non-redundant_MAGs_proteins"
output_dir="/nfs5/MICRO/Thurber_Lab/jacob/MAG_processing_deepsea/annotated_mags_kegg"
database="/nfs5/MICRO/Thurber_Lab/jacob/kegg/prokaryotes_db.dmnd"

# Make sure the output directory exists
mkdir -p "$output_dir"

# Loop through each protein file in the input directory
for protein_file in "$input_dir"/*.faa; do
  # Extract the base name of the protein file (without path and extension)
  protein_name=$(basename "$protein_file" .faa)

  # Define the output file name
  output_file="$output_dir/${protein_name}_kegg_annot.tsv"

  # Echo the DIAMOND annotation command
  echo "diamond blastp -d \"$database\" -q \"$protein_file\" -o \"$output_file\" -f 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore --max-target-seqs 1"
done

