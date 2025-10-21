#!/bin/bash
#SBATCH --job-name=cdhit_60_array
#SBATCH --account=micro
#SBATCH --qos=normal
#SBATCH --partition=micro
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --array=1-37%6
#SBATCH --output=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/cdhit_60_%A_%a.out
#SBATCH --error=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/cdhit_60_%A_%a.err
#SBATCH --mail-user=jacobwynne@ucsb.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# 60% jobfile (each line should be a cd-hit command with -c 0.60 -n 4 -M 61440 -T 16)
JOBFILE=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/cdhit60.txt

mkdir -p /nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs

CMD=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$JOBFILE")
if [ -z "$CMD" ]; then
  echo "No command for SLURM_ARRAY_TASK_ID=${SLURM_ARRAY_TASK_ID}"; exit 1
fi

echo "[$(date)] Node: $(hostname)"
echo "[$(date)] Task ${SLURM_ARRAY_TASK_ID} using ${SLURM_CPUS_PER_TASK} threads"
echo "Command: $CMD"
eval "$CMD"
echo "[$(date)] Task ${SLURM_ARRAY_TASK_ID} finished."
