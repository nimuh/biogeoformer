#!/bin/bash

# paths
db_dir="/nfs5/MICRO/Thurber_Lab/jacob/diamond_aug28/diamond_dbs"   
test_dir="/nfs5/MICRO/Thurber_Lab/jacob/diamond_aug28/test_fasta_aug26"
val_dir="/nfs5/MICRO/Thurber_Lab/jacob/diamond_aug28/val_fasta_aug26"
out_dir="/nfs5/MICRO/Thurber_Lab/jacob/diamond_aug28/diamond_out_fulloutput"

mkdir -p "$out_dir"

# make sure unmatched globs don’t run literally
shopt -s nullglob

# loop through databases
for db in "$db_dir"/final_selected_train_*_db.dmnd; do
    # extract the split number, e.g. 40 from final_selected_train_40_db.dmnd
    split=$(basename "$db" | sed -E 's/final_selected_train_([0-9]+)_db\.dmnd/\1/')

    # set corresponding query files
    test_query="$test_dir/final_selected_test_${split}.fasta"
    val_query="$val_dir/final_selected_val_${split}.fasta"

    if [[ -f "$test_query" ]]; then
        echo "diamond blastp --threads 32 -d $db -q $test_query \
            -o $out_dir/final_selected_test_${split}_vs_${split}.m8 \
            --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore \
            --max-target-seqs 1 \
            -e 1e308"
    fi

    if [[ -f "$val_query" ]]; then
        echo "diamond blastp --threads 32 -d $db -q $val_query \
            -o $out_dir/final_selected_val_${split}_vs_${split}.m8 \
            --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore \
            --max-target-seqs 1 \
            -e 1e308"
    fi
done
