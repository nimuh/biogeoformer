#!/bin/bash
#SBATCH --job-name=cdhit20_01_array
#SBATCH --account=zoidberg
#SBATCH --qos=normal
#SBATCH --partition=zoidberg
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --array=1-12%12
#SBATCH --output=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/cdhit20_01_%A_%a.out
#SBATCH --error=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/cdhit20_01_%A_%a.err
#SBATCH --mail-user=jacobwynne@ucsb.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# Path to jobfile
JOBFILE=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/cdhit20_part_01

# Grab the command for this array task
CMD=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$JOBFILE")

echo "[$(date)] Starting task $SLURM_ARRAY_TASK_ID on $SLURM_CPUS_PER_TASK threads"
echo "Command: $CMD"

# Run command
eval $CMD

echo "[$(date)] Task $SLURM_ARRAY_TASK_ID finished"
