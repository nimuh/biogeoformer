#!/bin/bash

# Input and output directories
input_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/cycle_split_check/famsa_alignments"
output_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/cycle_split_check/hmm_models"
mkdir -p "$output_dir"

# Similarity levels (20 through 100, step of 10)
similarities=($(seq 20 10 100))

# Output text file
cmd_file="run_hmmbuild_aug26.txt"
> "$cmd_file"   # clear if it exists

# Loop through each similarity
for similarity in "${similarities[@]}"; do
    for aln_file in "$input_dir"/selected_train_"$similarity"_*.aln; do
        base_name=$(basename "$aln_file" .aln)
        hmm_file="${output_dir}/${base_name}.hmm"

        echo "hmmbuild $hmm_file $aln_file" >> "$cmd_file"
    done
done

echo "Wrote commands to $cmd_file"
