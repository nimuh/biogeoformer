#!/bin/bash

# Set the input and output directories
input_dir="/nfs5/MICRO/Thurber_Lab/jacob/MAG_processing_deepsea/non-redundant_MAGs"
output_dir="/nfs5/MICRO/Thurber_Lab/jacob/MAG_processing_deepsea/non-redundant_MAGs_nucleotides"

# Make sure the output directory exists
mkdir -p "$output_dir"

# Loop through each .fa file in the input directory
for mag_file in "$input_dir"/*.fa; do
  # Extract the base name of the MAG file (without path and extension)
  mag_name=$(basename "$mag_file" .fa)

  # Define the Prodigal output file name for nucleotides
  output_file="$output_dir/${mag_name}_prodigal.fna"

  # Echo the Prodigal command to be submitted as an array job
  echo "prodigal -i \"$mag_file\" -d \"$output_file\" -p meta"
done

