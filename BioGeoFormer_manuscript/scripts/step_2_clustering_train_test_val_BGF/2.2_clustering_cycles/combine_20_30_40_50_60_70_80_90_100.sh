#!/bin/bash

dir_prev="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_20_30/split_data_20_30_40/split_data_20_30_40_50/split_data_20_30_40_50_60/split_data_20_30_40_50_60_70/split_data_20_30_40_50_60_70_80/split_data_20_30_40_50_60_70_80_90"
dir_100="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_100"
out="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_20_30/split_data_20_30_40/split_data_20_30_40_50/split_data_20_30_40_50_60/split_data_20_30_40_50_60_70/split_data_20_30_40_50_60_70_80/split_data_20_30_40_50_60_70_80_90/split_data_20_30_40_50_60_70_80_90_100"
mkdir -p "$out"

for f in "$dir_prev"/*_from20_30_40_50_60_70_80_90.clstr; do
  base=$(basename "$f" _from20_30_40_50_60_70_80_90.clstr)
  f100="$dir_100/${base}_c100.faa.clstr"
  if [[ -f "$f100" ]]; then
    clstr_rev.pl "$f100" "$f" > "$out/${base}_from20_30_40_50_60_70_80_90_100.clstr"
  else
    echo "Warning: $f100 does not exist"
  fi
done

