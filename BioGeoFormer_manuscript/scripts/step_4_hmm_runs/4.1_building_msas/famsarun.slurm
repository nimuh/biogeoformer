#!/bin/bash
#
# run_famsa_array.slurm
#
#SBATCH --job-name=famsa_array
#SBATCH --partition=zoidberg             # partition/queue to use
#SBATCH --account=zoidberg               # account is also zoidberg
#SBATCH --array=1-330%6                  # 330 tasks, max 6 running at once
#SBATCH --cpus-per-task=16               # 16 threads per task
#SBATCH --mem=64G                        # 64 GB RAM per task
#SBATCH --time=2-00:00:00                # adjust if you need more/less time
#SBATCH --output=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/famsa_%A_%a.out
#SBATCH --error=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/famsa_%A_%a.err
#SBATCH --mail-user=jacobwynne@ucsb.edu  # optional
#SBATCH --mail-type=END,FAIL             # optional

set -euo pipefail

LIST="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/famsarun.txt"
LOGDIR="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs"
mkdir -p "$LOGDIR"

# Threading hints
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export OPENBLAS_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export MKL_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export NUMEXPR_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export VECLIB_MAXIMUM_THREADS=${SLURM_CPUS_PER_TASK}
export BLIS_NUM_THREADS=${SLURM_CPUS_PER_TASK}

# Grab the command for this array index
CMD="$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$LIST" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"

if [[ -z "${CMD}" || "${CMD}" =~ ^# ]]; then
  echo "Task ${SLURM_ARRAY_TASK_ID}: empty or commented line; skipping."
  exit 0
fi

echo "[$(date)] Task ${SLURM_ARRAY_TASK_ID} on ${SLURMD_NODENAME}"
echo "Command: ${CMD}"

srun --ntasks=1 --cpus-per-task="${SLURM_CPUS_PER_TASK}" --cpu-bind=cores bash -lc "${CMD}"

echo "[$(date)] Task ${SLURM_ARRAY_TASK_ID} completed."
