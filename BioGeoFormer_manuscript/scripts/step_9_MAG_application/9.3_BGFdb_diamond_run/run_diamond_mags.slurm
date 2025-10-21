#!/bin/bash
#SBATCH --job-name=diamond_mags
#SBATCH --account=micro
#SBATCH --partition=micro
#SBATCH --qos=normal
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=48:00:00
#SBATCH --output=logs/diamond_mags_%j.out
#SBATCH --error=logs/diamond_mags_%j.err
#SBATCH --mail-user=jacobwynne@ucsb.edu
#SBATCH --mail-type=END,FAIL

# make sure logs directory exists
mkdir -p logs

# set paths manually
db="/nfs5/MICRO/Thurber_Lab/jacob/diamond_aug28/full_database/full_dbs/combined_100_aug26_db.dmnd"
query="/nfs5/MICRO/Thurber_Lab/jacob/hmm_runs/deepsea_mags_application/MAGs_combined_prodigal_cleaned.faa"
out="/nfs5/MICRO/Thurber_Lab/jacob/diamond_aug28/mag_output/mags_diamond_output_sep10.m8"

# make sure output directory exists
mkdir -p "$(dirname "$out")"

echo "[$(date)] Starting DIAMOND run"
diamond blastp --threads $SLURM_CPUS_PER_TASK -d "$db" -q "$query" \
    -o "$out" \
    --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore \
    --max-target-seqs 1
echo "[$(date)] Finished DIAMOND run"
