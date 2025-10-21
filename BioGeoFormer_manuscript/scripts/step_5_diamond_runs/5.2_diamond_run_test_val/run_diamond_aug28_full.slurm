#!/bin/bash
#SBATCH --job-name=diamond_blastp_full
#SBATCH --account=micro
#SBATCH --qos=normal
#SBATCH --partition=micro
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=48:00:00
#SBATCH --array=1-68%4
#SBATCH --output=/nfs5/MICRO/Thurber_Lab/jacob/diamond_aug28/scripts/logs/diamond_blastp_full_%A_%a.out
#SBATCH --error=/nfs5/MICRO/Thurber_Lab/jacob/diamond_aug28/scripts/logs/diamond_blastp_full_%A_%a.err
#SBATCH --mail-user=jacobwynne@ucsb.edu
#SBATCH --mail-type=END,FAIL

# Path to the command file
CMD_FILE=/nfs5/MICRO/Thurber_Lab/jacob/diamond_aug28/scripts/run_diamond_aug28_full.txt

# Extract the command for this array index
CMD=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $CMD_FILE)

if [[ -z "$CMD" ]]; then
    echo "[$(date)] Job ${SLURM_ARRAY_TASK_ID}: No command found (empty line in file)"
    exit 1
fi

echo "[$(date)] Running job ${SLURM_ARRAY_TASK_ID} of 68: $CMD"
eval $CMD
