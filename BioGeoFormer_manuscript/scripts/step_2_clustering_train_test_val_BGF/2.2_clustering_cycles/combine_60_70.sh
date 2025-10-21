#!/bin/bash

# Define the directories
dir_60="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_60"
dir_70="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_70"
output_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_60_70"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Iterate over the files in the split_data_60 directory
for file_60 in "$dir_60"/*_c60.faa.clstr; do
    # Extract the base name of the file
    base_name=$(basename "$file_60" _c60.faa.clstr)
    
    # Define the corresponding file in the split_data_70 directory
    file_70="$dir_70/${base_name}_c70.faa.clstr"
    
    # Check if the corresponding file exists
    if [[ -f "$file_70" ]]; then
        # Define the output file name
        output_file="$output_dir/${base_name}_from60_70.clstr"
        
        # Execute the clstr_rev.pl command
        clstr_rev.pl "$file_70" "$file_60" > "$output_file"
    else
        echo "Warning: $file_70 does not exist"
    fi
done

