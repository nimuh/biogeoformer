#!/bin/bash

# Define the directories
dir_40_50_60_70_80_90="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_40_50/split_data_40_50_60/split_data_40_50_60_70/split_data_40_50_60_70_80/split_data_40_50_60_70_80_90"
dir_100="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_100"
output_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_40_50/split_data_40_50_60/split_data_40_50_60_70/split_data_40_50_60_70_80/split_data_40_50_60_70_80_90/split_data_40_50_60_70_80_90_100"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Iterate over the files in the split_data_40_50_60_70_80_90 directory
for file_40_50_60_70_80_90 in "$dir_40_50_60_70_80_90"/*_from40_50_60_70_80_90.clstr; do
    # Extract the base name of the file
    base_name=$(basename "$file_40_50_60_70_80_90" _from40_50_60_70_80_90.clstr)
    
    # Define the corresponding file in the split_data_100 directory
    file_100="$dir_100/${base_name}_c100.faa.clstr"
    
    # Check if the corresponding file exists
    if [[ -f "$file_100" ]]; then
        # Define the output file name
        output_file="$output_dir/${base_name}_from40_50_60_70_80_90_100.clstr"
        
        # Execute the clstr_rev.pl command
        clstr_rev.pl "$file_100" "$file_40_50_60_70_80_90" > "$output_file"
    else
        echo "Warning: $file_100 does not exist"
    fi
done

