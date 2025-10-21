#!/bin/bash

dir_prev="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_20_30/split_data_20_30_40/split_data_20_30_40_50"
dir_60="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_60"
out="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_20_30/split_data_20_30_40/split_data_20_30_40_50/split_data_20_30_40_50_60"
mkdir -p "$out"

for f in "$dir_prev"/*_from20_30_40_50.clstr; do
  base=$(basename "$f" _from20_30_40_50.clstr)
  f60="$dir_60/${base}_c60.faa.clstr"
  if [[ -f "$f60" ]]; then
    clstr_rev.pl "$f60" "$f" > "$out/${base}_from20_30_40_50_60.clstr"
  else
    echo "Warning: $f60 does not exist"
  fi
done
