#!/bin/bash

# set paths manually
db="/nfs5/MICRO/Thurber_Lab/jacob/diamond_aug28/full_database/full_dbs/combined_100_aug26_db.dmnd"        # diamond database
query="/nfs5/MICRO/Thurber_Lab/jacob/hmm_runs/deepsea_mags_application/MAGs_combined_prodigal_cleaned.faa"       # query fasta file
out="/nfs5/MICRO/Thurber_Lab/jacob/diamond_aug28/mag_output/mags_diamond_output_sep10.m8"           # output file

# make sure output directory exists
mkdir -p "$(dirname "$out")"

# run diamond
diamond blastp --threads 32 -d "$db" -q "$query" \
    -o "$out" \
    --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore \
    --max-target-seqs 1
