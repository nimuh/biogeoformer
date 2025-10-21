#!/bin/bash

dir_30_40_50_60_70="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_30_40_50_60_70"
dir_80="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_80"
output_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_30_40_50_60_70_80"

mkdir -p "$output_dir"

for file_30_40_50_60_70 in "$dir_30_40_50_60_70"/*_from30_40_50_60_70.clstr; do
    base_name=$(basename "$file_30_40_50_60_70" _from30_40_50_60_70.clstr)
    file_80="$dir_80/${base_name}_c80.faa.clstr"
    if [[ -f "$file_80" ]]; then
        output_file="$output_dir/${base_name}_from30_40_50_60_70_80.clstr"
        clstr_rev.pl "$file_80" "$file_30_40_50_60_70" > "$output_file"
    else
        echo "Warning: $file_80 does not exist"
    fi
done

