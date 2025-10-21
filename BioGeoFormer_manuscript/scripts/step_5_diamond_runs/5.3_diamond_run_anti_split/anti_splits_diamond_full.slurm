#!/bin/bash
#SBATCH --job-name=anti_splits_diamond_full
#SBATCH --account=micro
#SBATCH --qos=normal
#SBATCH --partition=micro
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=48:00:00
#SBATCH --array=1-9%4
#SBATCH --output=/nfs5/MICRO/Thurber_Lab/jacob/diamond_aug28/scripts/logs/anti_splits_diamond_full_%A_%a.out
#SBATCH --error=/nfs5/MICRO/Thurber_Lab/jacob/diamond_aug28/scripts/logs/anti_splits_diamond_full_%A_%a.err
#SBATCH --mail-user=jacobwynne@ucsb.edu
#SBATCH --mail-type=END,FAIL

# path to command file
CMD_FILE=/nfs5/MICRO/Thurber_Lab/jacob/diamond_aug28/scripts/anti_splits_diamond_full.txt

# select the command for this task
CMD=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $CMD_FILE)

if [[ -z "$CMD" ]]; then
    echo "[$(date)] No command found for task ${SLURM_ARRAY_TASK_ID}"
    exit 1
fi

# make sure logs directory exists
mkdir -p /nfs5/MICRO/Thurber_Lab/jacob/diamond_aug28/scripts/logs

echo "[$(date)] Running task ${SLURM_ARRAY_TASK_ID}: $CMD"
eval $CMD

