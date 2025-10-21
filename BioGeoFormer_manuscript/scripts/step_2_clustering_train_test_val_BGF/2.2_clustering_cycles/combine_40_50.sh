#!/bin/bash

# Define the directories
dir_40="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_40"
dir_50="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_50"
output_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_40_50"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Iterate over the files in the split_data_40 directory
for file_40 in "$dir_40"/*_c40.faa.clstr; do
    # Extract the base name of the file
    base_name=$(basename "$file_40" _c40.faa.clstr)
    
    # Define the corresponding file in the split_data_50 directory
    file_50="$dir_50/${base_name}_c50.faa.clstr"
    
    # Check if the corresponding file exists
    if [[ -f "$file_50" ]]; then
        # Define the output file name
        output_file="$output_dir/${base_name}_from40_50.clstr"
        
        # Execute the clstr_rev.pl command
        clstr_rev.pl "$file_50" "$file_40" > "$output_file"
    else
        echo "Warning: $file_50 does not exist"
    fi
done
