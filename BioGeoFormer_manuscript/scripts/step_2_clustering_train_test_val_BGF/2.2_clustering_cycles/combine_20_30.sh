#!/bin/bash

dir_20="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_20"
dir_30="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_30"
out="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_20_30"
mkdir -p "$out"

for f20 in "$dir_20"/*_c20.faa.clstr; do
  base=$(basename "$f20" _c20.faa.clstr)
  f30="$dir_30/${base}_c30.faa.clstr"
  if [[ -f "$f30" ]]; then
    clstr_rev.pl "$f30" "$f20" > "$out/${base}_from20_30.clstr"
  else
    echo "Warning: $f30 does not exist"
  fi
done
