#!/bin/bash

# Define the directories
dir_70="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_70"
dir_80="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_80"
output_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_70_80"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Iterate over the files in the split_data_70 directory
for file_70 in "$dir_70"/*_c70.faa.clstr; do
    # Extract the base name of the file
    base_name=$(basename "$file_70" _c70.faa.clstr)
    
    # Define the corresponding file in the split_data_80 directory
    file_80="$dir_80/${base_name}_c80.faa.clstr"
    
    # Check if the corresponding file exists
    if [[ -f "$file_80" ]]; then
        # Define the output file name
        output_file="$output_dir/${base_name}_from70_80.clstr"
        
        # Execute the clstr_rev.pl command
        clstr_rev.pl "$file_80" "$file_70" > "$output_file"
    else
        echo "Warning: $file_80 does not exist"
    fi
done
