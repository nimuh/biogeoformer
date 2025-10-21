#!/bin/bash

dir_30_40_50="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_30_40_50"
dir_60="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_60"
output_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_30_40_50_60"

mkdir -p "$output_dir"

for file_30_40_50 in "$dir_30_40_50"/*_from30_40_50.clstr; do
    base_name=$(basename "$file_30_40_50" _from30_40_50.clstr)
    file_60="$dir_60/${base_name}_c60.faa.clstr"
    if [[ -f "$file_60" ]]; then
        output_file="$output_dir/${base_name}_from30_40_50_60.clstr"
        clstr_rev.pl "$file_60" "$file_30_40_50" > "$output_file"
    else
        echo "Warning: $file_60 does not exist"
    fi
done
