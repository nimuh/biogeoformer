#!/bin/bash

dir_30_40_50_60_70_80_90="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_30_40_50_60_70_80_90"
dir_100="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_100"
output_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_30_40_50_60_70_80_90_100"

mkdir -p "$output_dir"

for file_30_40_50_60_70_80_90 in "$dir_30_40_50_60_70_80_90"/*_from30_40_50_60_70_80_90.clstr; do
    base_name=$(basename "$file_30_40_50_60_70_80_90" _from30_40_50_60_70_80_90.clstr)
    file_100="$dir_100/${base_name}_c100.faa.clstr"
    if [[ -f "$file_100" ]]; then
        output_file="$output_dir/${base_name}_from30_40_50_60_70_80_90_100.clstr"
        clstr_rev.pl "$file_100" "$file_30_40_50_60_70_80_90" > "$output_file"
    else
        echo "Warning: $file_100 does not exist"
    fi
done

