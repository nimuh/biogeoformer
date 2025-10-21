#!/bin/bash

# Define the directories
dir_50="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_50"
dir_60="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_60"
output_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_50_60"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Iterate over the files in the split_data_50 directory
for file_50 in "$dir_50"/*_c50.faa.clstr; do
    # Extract the base name of the file
    base_name=$(basename "$file_50" _c50.faa.clstr)
    
    # Define the corresponding file in the split_data_60 directory
    file_60="$dir_60/${base_name}_c60.faa.clstr"
    
    # Check if the corresponding file exists
    if [[ -f "$file_60" ]]; then
        # Define the output file name
        output_file="$output_dir/${base_name}_from50_60.clstr"
        
        # Execute the clstr_rev.pl command
        clstr_rev.pl "$file_60" "$file_50" > "$output_file"
    else
        echo "Warning: $file_60 does not exist"
    fi
done

