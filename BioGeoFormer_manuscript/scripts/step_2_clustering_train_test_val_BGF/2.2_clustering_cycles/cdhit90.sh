#!/bin/bash

# Define the input directory and the output directory for 90% similarity threshold
input_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_100"
output_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_90"

# Make output directory if it does not exist
mkdir -p "$output_dir"

# Print cd-hit commands for each file at 90% threshold
for file in "$input_dir"/*.faa; do
    filename=$(basename "$file")
    output_filename="${filename#combined100_}"
    output_file="${output_dir}/${output_filename%_c100.faa}_c90.faa"
    echo "cd-hit -i \"$file\" -o \"$output_file\" -c 0.90 -n 5 -M 61440 -T 16"
done
