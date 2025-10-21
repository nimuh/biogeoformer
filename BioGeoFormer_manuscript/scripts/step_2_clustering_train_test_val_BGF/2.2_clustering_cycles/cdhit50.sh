#!/bin/bash

# Define the input directory and the output directory for 50% similarity threshold
input_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_60"
output_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_50"

# Make output directory if it does not exist
mkdir -p "$output_dir"

# Print cd-hit commands for each file at 50% threshold
for file in "$input_dir"/*.faa; do
    filename=$(basename "$file")
    output_filename="${filename%_c60.faa}_c50.faa"
    output_file="${output_dir}/${output_filename}"
    echo "cd-hit -i \"$file\" -o \"$output_file\" -c 0.50 -n 3 -M 61440 -T 16"
done
