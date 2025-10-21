#!/bin/bash

dir_prev="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_20_30/split_data_20_30_40/split_data_20_30_40_50/split_data_20_30_40_50_60/split_data_20_30_40_50_60_70/split_data_20_30_40_50_60_70_80"
dir_90="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_90"
out="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_20_30/split_data_20_30_40/split_data_20_30_40_50/split_data_20_30_40_50_60/split_data_20_30_40_50_60_70/split_data_20_30_40_50_60_70_80/split_data_20_30_40_50_60_70_80_90"
mkdir -p "$out"

for f in "$dir_prev"/*_from20_30_40_50_60_70_80.clstr; do
  base=$(basename "$f" _from20_30_40_50_60_70_80.clstr)
  f90="$dir_90/${base}_c90.faa.clstr"
  if [[ -f "$f90" ]]; then
    clstr_rev.pl "$f90" "$f" > "$out/${base}_from20_30_40_50_60_70_80_90.clstr"
  else
    echo "Warning: $f90 does not exist"
  fi
done
