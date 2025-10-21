#!/bin/bash

dir_prev="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_20_30/split_data_20_30_40/split_data_20_30_40_50/split_data_20_30_40_50_60/split_data_20_30_40_50_60_70"
dir_80="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_80"
out="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_20_30/split_data_20_30_40/split_data_20_30_40_50/split_data_20_30_40_50_60/split_data_20_30_40_50_60_70/split_data_20_30_40_50_60_70_80"
mkdir -p "$out"

for f in "$dir_prev"/*_from20_30_40_50_60_70.clstr; do
  base=$(basename "$f" _from20_30_40_50_60_70.clstr)
  f80="$dir_80/${base}_c80.faa.clstr"
  if [[ -f "$f80" ]]; then
    clstr_rev.pl "$f80" "$f" > "$out/${base}_from20_30_40_50_60_70_80.clstr"
  else
    echo "Warning: $f80 does not exist"
  fi
done
