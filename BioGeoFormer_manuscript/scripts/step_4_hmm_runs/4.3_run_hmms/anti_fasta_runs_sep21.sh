#!/bin/bash

# Directories
hmm_model_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/cycle_split_check/hmm_models"
anti_fasta_dir="/nfs5/MICRO/Thurber_Lab/jacob/hmm_runs_sep2/anti_split_fasta"
output_dir="/nfs5/MICRO/Thurber_Lab/jacob/hmm_runs_sep2/anti_split_output"

mkdir -p "$output_dir"

# Loop over HMM models
for hmm_model in ${hmm_model_dir}/selected_train_*.hmm; do
    # Extract similarity (e.g., 90 from selected_train_90_phos_other.hmm)
    similarity=$(basename "$hmm_model" | grep -oP 'selected_train_\K[0-9]+')

    # Look for matching anti-split FASTA file
    for fasta_file in ${anti_fasta_dir}/merged_anti_split_${similarity}.fasta; do
        if [[ -f $fasta_file ]]; then
            model_base=$(basename "$hmm_model" .hmm)
            output_file="${output_dir}/${model_base}_on_anti_split_${similarity}.tblout"

            # Print permissive hmmsearch command (tabular only)
            echo "hmmsearch --max -E 1e308 --domE 1e308 --tblout $output_file $hmm_model $fasta_file"
        fi
    done
done
