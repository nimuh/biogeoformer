#!/bin/bash

# Directories
hmm_model_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/cycle_split_check/hmm_models"
val_fasta_dir="/nfs5/MICRO/Thurber_Lab/jacob/hmm_runs_sep2/val_fasta_aug26"
output_dir="/nfs5/MICRO/Thurber_Lab/jacob/hmm_runs_sep2/val_output_aug26_full"

mkdir -p "$output_dir"

# Loop over HMM models
for hmm_model in ${hmm_model_dir}/selected_train_*.hmm; do
    # Extract similarity (e.g., 90 from selected_train_90_phos_other.hmm)
    similarity=$(basename "$hmm_model" | grep -oP 'selected_train_\K[0-9]+')

    # Look for matching FASTA file with correct prefix
    for fasta_file in ${val_fasta_dir}/final_selected_val_${similarity}.fasta; do
        if [[ -f $fasta_file ]]; then
            model_base=$(basename "$hmm_model" .hmm)
            output_file="${output_dir}/${model_base}_on_val_${similarity}.tblout"

            # Print permissive hmmsearch command (tabular only)
            echo "hmmsearch --max -E 1e308 --domE 1e308 --tblout $output_file $hmm_model $fasta_file"
        fi
    done
done
