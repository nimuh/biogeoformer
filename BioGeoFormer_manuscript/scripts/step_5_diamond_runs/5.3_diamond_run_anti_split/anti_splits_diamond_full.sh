#!/bin/bash

# paths
db_dir="/nfs5/MICRO/Thurber_Lab/jacob/diamond_aug28/diamond_dbs"
anti_dir="/nfs5/MICRO/Thurber_Lab/jacob/diamond_aug28/anti_splits"
out_dir="/nfs5/MICRO/Thurber_Lab/jacob/diamond_aug28/diamond_out"

mkdir -p "$out_dir"
shopt -s nullglob

# loop through anti_split FASTAs
for query in "$anti_dir"/anti_split_*.fasta; do
    # extract similarity number (e.g., 40 from anti_split_40.fasta)
    split=$(basename "$query" | sed -E 's/anti_split_([0-9]+)\.fasta/\1/')

    # find the matching DB
    db="$db_dir/final_selected_train_${split}_db.dmnd"

    if [[ -f "$db" ]]; then
        echo "diamond blastp --threads 32 -d $db -q $query \
            -o $out_dir/anti_split_full_${split}_vs_${split}.m8 \
            --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore \
            --max-target-seqs 1 \
            -e 1e308"
    else
        echo \"⚠️ No matching DB found for similarity $split\"
    fi
done
