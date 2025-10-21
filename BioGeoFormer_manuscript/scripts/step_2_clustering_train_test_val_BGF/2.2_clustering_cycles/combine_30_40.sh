#!/bin/bash

dir_30="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_30"
dir_40="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_40"
output_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_30_40"

mkdir -p "$output_dir"

for file_30 in "$dir_30"/*_c30.faa.clstr; do
    base_name=$(basename "$file_30" _c30.faa.clstr)
    file_40="$dir_40/${base_name}_c40.faa.clstr"
    if [[ -f "$file_40" ]]; then
        output_file="$output_dir/${base_name}_from30_40.clstr"
        clstr_rev.pl "$file_40" "$file_30" > "$output_file"
    else
        echo "Warning: $file_40 does not exist"
    fi
done
