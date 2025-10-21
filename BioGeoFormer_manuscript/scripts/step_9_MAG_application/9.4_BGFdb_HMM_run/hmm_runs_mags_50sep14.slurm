#!/bin/bash
#SBATCH --job-name=hmm_mags_sep14_50
#SBATCH --account=micro
#SBATCH --partition=micro
#SBATCH --qos=normal
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --array=1-37%4
#SBATCH --output=/nfs5/MICRO/Thurber_Lab/jacob/hmm_runs_sep2/logs/hmm_mags_sep14_%A_%a.out
#SBATCH --error=/nfs5/MICRO/Thurber_Lab/jacob/hmm_runs_sep2/logs/hmm_mags_sep14_%A_%a.err
#SBATCH --mail-user=jacobwynne@ucsb.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# Paths
SCRIPT_DIR=/nfs5/MICRO/Thurber_Lab/jacob/hmm_runs_sep2/scripts
RUN_FILE=${SCRIPT_DIR}/hmm_runs_mags_50_sep14.txt

# Get the command for this array task
CMD=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$RUN_FILE")

# Safety check: only run if line isn’t empty or a comment
if [[ -n "$CMD" && ! "$CMD" =~ ^# ]]; then
    echo "[$(date)] Starting task $SLURM_ARRAY_TASK_ID"
    eval "$CMD"
    echo "[$(date)] Finished task $SLURM_ARRAY_TASK_ID"
else
    echo "[$(date)] Skipping empty/comment line at $SLURM_ARRAY_TASK_ID"
fi
