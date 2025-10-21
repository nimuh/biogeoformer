#!/bin/bash

dir_20_30="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_20_30"
dir_40="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_40"
out="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_20_30/split_data_20_30_40"
mkdir -p "$out"

for f2030 in "$dir_20_30"/*_from20_30.clstr; do
  base=$(basename "$f2030" _from20_30.clstr)
  f40="$dir_40/${base}_c40.faa.clstr"
  if [[ -f "$f40" ]]; then
    clstr_rev.pl "$f40" "$f2030" > "$out/${base}_from20_30_40.clstr"
  else
    echo "Warning: $f40 does not exist"
  fi
done
