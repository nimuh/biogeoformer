#!/bin/bash
#SBATCH --job-name=cdhit_30_array
#SBATCH --account=micro
#SBATCH --qos=normal
#SBATCH --partition=micro
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --array=1-37%6
#SBATCH --output=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/cdhit_30_%A_%a.out
#SBATCH --error=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/cdhit_30_%A_%a.err
#SBATCH --mail-user=jacobwynne@ucsb.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# One psi-cd-hit command per line:
JOBFILE=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/cdhit30.txt

# Ensure logs dir exists
mkdir -p /nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs

# Optional: load modules if your cluster uses them
# module load cd-hit
# module load blast

# Grab the Nth command from the jobfile
CMD=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$JOBFILE")
if [ -z "$CMD" ]; then
  echo "No command found for SLURM_ARRAY_TASK_ID=${SLURM_ARRAY_TASK_ID}. Exiting."
  exit 1
fi

echo "[$(date)] Host: $(hostname)"
echo "[$(date)] Task ${SLURM_ARRAY_TASK_ID} using ${SLURM_CPUS_PER_TASK} CPUs; mem=${SLURM_MEM_PER_NODE:-$SLURM_MEM_PER_CPU}"
echo "Command: $CMD"
eval "$CMD"
echo "[$(date)] Task ${SLURM_ARRAY_TASK_ID} finished."
