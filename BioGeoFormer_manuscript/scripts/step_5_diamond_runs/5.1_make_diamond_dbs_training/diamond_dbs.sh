#!/bin/bash

# input folder containing fasta files
in_dir="/nfs5/MICRO/Thurber_Lab/jacob/diamond_aug28/train_fasta_aug26"
# output folder for diamond databases
out_dir="/nfs5/MICRO/Thurber_Lab/jacob/diamond_aug28/diamond_dbs"

mkdir -p "$out_dir"

for file in "$in_dir"/*.fasta; do
    base=$(basename "$file" .fasta)
    echo "diamond makedb --in $file -d $out_dir/${base}_db"
done
