#!/bin/bash

dir_30_40_50_60="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_30_40_50_60"
dir_70="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_70"
output_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_30_40_50_60_70"

mkdir -p "$output_dir"

for file_30_40_50_60 in "$dir_30_40_50_60"/*_from30_40_50_60.clstr; do
    base_name=$(basename "$file_30_40_50_60" _from30_40_50_60.clstr)
    file_70="$dir_70/${base_name}_c70.faa.clstr"
    if [[ -f "$file_70" ]]; then
        output_file="$output_dir/${base_name}_from30_40_50_60_70.clstr"
        clstr_rev.pl "$file_70" "$file_30_40_50_60" > "$output_file"
    else
        echo "Warning: $file_70 does not exist"
    fi
done
