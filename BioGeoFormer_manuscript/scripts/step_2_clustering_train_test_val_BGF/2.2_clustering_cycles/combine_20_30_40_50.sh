#!/bin/bash

dir_20_30_40="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_20_30/split_data_20_30_40"
dir_50="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_50"
out="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_20_30/split_data_20_30_40/split_data_20_30_40_50"
mkdir -p "$out"

for f in "$dir_20_30_40"/*_from20_30_40.clstr; do
  base=$(basename "$f" _from20_30_40.clstr)
  f50="$dir_50/${base}_c50.faa.clstr"
  if [[ -f "$f50" ]]; then
    clstr_rev.pl "$f50" "$f" > "$out/${base}_from20_30_40_50.clstr"
  else
    echo "Warning: $f50 does not exist"
  fi
done
