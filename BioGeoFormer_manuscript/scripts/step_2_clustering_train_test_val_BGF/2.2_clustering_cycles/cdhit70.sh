#!/bin/bash

# Define the input directory and the output directory for 70% similarity threshold
input_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_80"
output_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_70"

# Make output directory if it does not exist
mkdir -p "$output_dir"

# Print cd-hit commands for each file at 70% threshold
for file in "$input_dir"/*.faa; do
    filename=$(basename "$file")
    output_filename="${filename%_c80.faa}_c70.faa"
    output_file="${output_dir}/${output_filename}"
    echo "cd-hit -i \"$file\" -o \"$output_file\" -c 0.70 -n 5 -M 61440 -T 16"
done

