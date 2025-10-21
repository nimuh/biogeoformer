#!/bin/bash

# Define the directories
dir_60_70_80="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_60_70/split_data_60_70_80"
dir_90="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_90"
output_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_60_70/split_data_60_70_80/split_data_60_70_80_90"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Iterate over the files in the split_data_60_70_80 directory
for file_60_70_80 in "$dir_60_70_80"/*_from60_70_80.clstr; do
    # Extract the base name of the file
    base_name=$(basename "$file_60_70_80" _from60_70_80.clstr)
    
    # Define the corresponding file in the split_data_90 directory
    file_90="$dir_90/${base_name}_c90.faa.clstr"
    
    # Check if the corresponding file exists
    if [[ -f "$file_90" ]]; then
        # Define the output file name
        output_file="$output_dir/${base_name}_from60_70_80_90.clstr"
        
        # Execute the clstr_rev.pl command
        clstr_rev.pl "$file_90" "$file_60_70_80" > "$output_file"
    else
        echo "Warning: $file_90 does not exist"
    fi
done
