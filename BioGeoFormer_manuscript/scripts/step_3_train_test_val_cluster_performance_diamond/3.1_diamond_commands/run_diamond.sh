#!/bin/bash

# Define the folder containing your files
folder_path="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/cycle_split_check"
output_path="${folder_path}/diamond_output"
mkdir -p "$output_path"

# Loop through each selected_val_ and selected_test_ fasta file
for fasta_file in "$folder_path"/selected_{val,test}_*.fasta; do
  # Extract the base name without the extension
  base_name=$(basename "$fasta_file" .fasta)
  
  # Extract the cycle and identifier from the file name
  # Example: selected_test_40_aceti_met.fasta → cycle=40, identifier=aceti_met
  cycle=$(echo "$base_name" | cut -d'_' -f3)
  identifier=$(echo "$base_name" | cut -d'_' -f4-)

  # Find the corresponding train .dmnd database
  db_file="$folder_path/selected_train_${cycle}_${identifier}_db.dmnd"
  
  if [[ -f "$db_file" ]]; then
    # Run DIAMOND alignment with binary output (.daa)
    echo "diamond blastp -d $db_file -q $fasta_file -o ${output_path}/${base_name}_aligned.daa --max-target-seqs 1"
  else
    echo "No matching train .dmnd file found for $fasta_file"
  fi
done
