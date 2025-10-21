#!/bin/bash
#SBATCH --job-name=clstr2txt_array
#SBATCH --account=micro
#SBATCH --qos=normal
#SBATCH --partition=micro
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=12:00:00
#SBATCH --output=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/clstr2txt_%A_%a.out
#SBATCH --error=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/clstr2txt_%A_%a.err
#SBATCH --mail-user=jacobwynne@ucsb.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --array=1-330%60
#              ^^^^
#  1-19 = total number of jobs (19 lines in your .txt file)
#  %5   = max 5 jobs run at the same time (you can change this)

# Path to the command list file
CMD_FILE="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/cluster_to_tables.txt"

set -euo pipefail

LOG_DIR="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs"
mkdir -p "$LOG_DIR"

# Ensure single-threaded behavior
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1

# Read non-empty, non-comment lines
mapfile -t CMDS < <(grep -vE '^\s*($|#)' "$CMD_FILE")

TASK_INDEX=$((SLURM_ARRAY_TASK_ID - 1))

if (( TASK_INDEX < 0 || TASK_INDEX >= ${#CMDS[@]} )); then
  echo "Array index ${SLURM_ARRAY_TASK_ID} out of bounds (have ${#CMDS[@]} commands)."
  exit 2
fi

CMD="${CMDS[$TASK_INDEX]}"

echo "[$(date)] Node: $(hostname)"
echo "[$(date)] Running task ${SLURM_ARRAY_TASK_ID}/${#CMDS[@]}"
echo "[$(date)] Command: $CMD"

bash -lc "$CMD"

echo "[$(date)] Done."
