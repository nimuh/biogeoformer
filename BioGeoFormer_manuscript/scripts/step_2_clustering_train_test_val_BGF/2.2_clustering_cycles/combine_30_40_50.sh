#!/bin/bash

dir_30_40="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_30_40"
dir_50="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_50"
output_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_30_40_50"

mkdir -p "$output_dir"

for file_30_40 in "$dir_30_40"/*_from30_40.clstr; do
    base_name=$(basename "$file_30_40" _from30_40.clstr)
    file_50="$dir_50/${base_name}_c50.faa.clstr"
    if [[ -f "$file_50" ]]; then
        output_file="$output_dir/${base_name}_from30_40_50.clstr"
        clstr_rev.pl "$file_50" "$file_30_40" > "$output_file"
    else
        echo "Warning: $file_50 does not exist"
    fi
done
