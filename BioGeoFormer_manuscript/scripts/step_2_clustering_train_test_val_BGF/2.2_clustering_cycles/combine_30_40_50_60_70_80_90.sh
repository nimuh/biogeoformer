#!/bin/bash

dir_30_40_50_60_70_80="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_30_40_50_60_70_80"
dir_90="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_90"
output_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_30_40_50_60_70_80_90"

mkdir -p "$output_dir"

for file_30_40_50_60_70_80 in "$dir_30_40_50_60_70_80"/*_from30_40_50_60_70_80.clstr; do
    base_name=$(basename "$file_30_40_50_60_70_80" _from30_40_50_60_70_80.clstr)
    file_90="$dir_90/${base_name}_c90.faa.clstr"
    if [[ -f "$file_90" ]]; then
        output_file="$output_dir/${base_name}_from30_40_50_60_70_80_90.clstr"
        clstr_rev.pl "$file_90" "$file_30_40_50_60_70_80" > "$output_file"
    else
        echo "Warning: $file_90 does not exist"
    fi
done
