#!/bin/bash
#SBATCH --job-name=cdhit_80_array
#SBATCH --account=micro
#SBATCH --qos=normal
#SBATCH --partition=micro
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --array=1-37%6
#SBATCH --output=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/cdhit_80_%A_%a.out
#SBATCH --error=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/cdhit_80_%A_%a.err
#SBATCH --mail-user=jacobwynne@ucsb.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# Path to jobfile with cd-hit commands at 80% similarity
JOBFILE=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/cdhit80.txt

# Make sure logs dir exists
mkdir -p /nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs

# Pick the Nth command
CMD=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$JOBFILE")

if [ -z "$CMD" ]; then
  echo "No command found for SLURM_ARRAY_TASK_ID=${SLURM_ARRAY_TASK_ID}. Exiting."
  exit 1
fi

echo "[$(date)] Running task ${SLURM_ARRAY_TASK_ID} on ${SLURM_CPUS_PER_TASK} threads"
echo "Command: $CMD"
eval $CMD
echo "[$(date)] Task ${SLURM_ARRAY_TASK_ID} finished."
