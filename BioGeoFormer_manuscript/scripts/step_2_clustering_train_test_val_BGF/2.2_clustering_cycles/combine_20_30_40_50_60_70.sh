#!/bin/bash

dir_prev="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_20_30/split_data_20_30_40/split_data_20_30_40_50/split_data_20_30_40_50_60"
dir_70="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_70"
out="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_20_30/split_data_20_30_40/split_data_20_30_40_50/split_data_20_30_40_50_60/split_data_20_30_40_50_60_70"
mkdir -p "$out"

for f in "$dir_prev"/*_from20_30_40_50_60.clstr; do
  base=$(basename "$f" _from20_30_40_50_60.clstr)
  f70="$dir_70/${base}_c70.faa.clstr"
  if [[ -f "$f70" ]]; then
    clstr_rev.pl "$f70" "$f" > "$out/${base}_from20_30_40_50_60_70.clstr"
  else
    echo "Warning: $f70 does not exist"
  fi
done
