#!/bin/bash

# Directories and files
hmm_model_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/cycle_split_check/hmm_models/"
query_fasta="/nfs5/MICRO/Thurber_Lab/jacob/hmm_runs/deepsea_mags_application/MAGs_combined_prodigal_cleaned.faa"
output_dir="/nfs5/MICRO/Thurber_Lab/jacob/hmm_runs_sep2/deepsea_mag_application"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop over 90% clustered HMMs
for hmm_model in ${hmm_model_dir}/selected_train_50_*.hmm; do
    if [[ -f "$hmm_model" ]]; then
        # Extract model name
        model_base=$(basename "$hmm_model" .hmm)

        # Define output file path
        output_file="${output_dir}/${model_base}_on_deepsea_mags.txt"

        # Echo the hmmsearch command with 16 threads
        echo "hmmsearch --cpu 16 --tblout \"$output_file\" \"$hmm_model\" \"$query_fasta\""
    fi
done
