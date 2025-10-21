#!/bin/bash
#SBATCH --job-name=hmm_val_full
#SBATCH --account=zoidberg
#SBATCH --partition=zoidberg
#SBATCH --qos=normal
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --array=1-209%10
#SBATCH --output=/nfs5/MICRO/Thurber_Lab/jacob/hmm_runs_sep2/logs/hmm_val_full_%A_%a.out
#SBATCH --error=/nfs5/MICRO/Thurber_Lab/jacob/hmm_runs_sep2/logs/hmm_val_full_%A_%a.err
#SBATCH --mail-user=jacobwynne@ucsb.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# File with one hmmsearch command per line
CMD_FILE=/nfs5/MICRO/Thurber_Lab/jacob/hmm_runs_sep2/scripts/hmm_runs_val_sep2_full.txt

# Get the command for this task
CMD=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $CMD_FILE)

if [[ -z "$CMD" ]]; then
    echo "[$(date)] No command found for task $SLURM_ARRAY_TASK_ID"
    exit 1
fi

echo "[$(date)] Running task $SLURM_ARRAY_TASK_ID: $CMD"
eval $CMD
