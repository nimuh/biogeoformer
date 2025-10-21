#!/bin/bash

# Define the directories
dir_50_60_70="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_50_60/split_data_50_60_70"
dir_80="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_80"
output_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_50_60/split_data_50_60_70/split_data_50_60_70_80"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Iterate over the files in the split_data_50_60_70 directory
for file_50_60_70 in "$dir_50_60_70"/*_from50_60_70.clstr; do
    # Extract the base name of the file
    base_name=$(basename "$file_50_60_70" _from50_60_70.clstr)
    
    # Define the corresponding file in the split_data_80 directory
    file_80="$dir_80/${base_name}_c80.faa.clstr"
    
    # Check if the corresponding file exists
    if [[ -f "$file_80" ]]; then
        # Define the output file name
        output_file="$output_dir/${base_name}_from50_60_70_80.clstr"
        
        # Execute the clstr_rev.pl command
        clstr_rev.pl "$file_80" "$file_50_60_70" > "$output_file"
    else
        echo "Warning: $file_80 does not exist"
    fi
done

