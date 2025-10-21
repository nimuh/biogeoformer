#!/bin/bash
#SBATCH --job-name=diamond_makedb
#SBATCH --account=micro
#SBATCH --qos=normal
#SBATCH --partition=micro
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=2:00:00
#SBATCH --array=1-9
#SBATCH --output=/nfs5/MICRO/Thurber_Lab/jacob/diamond_aug28/scripts/logs/diamond_makedb_%A_%a.out
#SBATCH --error=/nfs5/MICRO/Thurber_Lab/jacob/diamond_aug28/scripts/logs/diamond_makedb_%A_%a.err
#SBATCH --mail-user=jacobwynne@ucsb.edu
#SBATCH --mail-type=END,FAIL

# Path to the command file
CMD_FILE=/nfs5/MICRO/Thurber_Lab/jacob/diamond_aug28/scripts/diamond_dbs.txt

# Extract the command for this array index
CMD=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $CMD_FILE)

echo "[$(date)] Running job ${SLURM_ARRAY_TASK_ID} of 9: $CMD"
eval $CMD
