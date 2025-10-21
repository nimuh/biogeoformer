#!/bin/bash
#SBATCH --job-name=combine_chain_20_to_100
#SBATCH --account=micro                 # <-- change if your cluster uses a different account
#SBATCH --qos=normal
#SBATCH --partition=micro               # <-- change partition if needed
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=96:00:00
#SBATCH --output=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/combine_chain_20_to_100_%j.out
#SBATCH --error=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/combine_chain_20_to_100_%j.err
#SBATCH --mail-user=jacobwynne@ucsb.edu
#SBATCH --mail-type=BEGIN,END,FAIL

SCRIPTS_DIR=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts

# Ensure logs dir exists
mkdir -p "$SCRIPTS_DIR/logs"

echo "[$(date)] Starting sequential combine jobs (20 → 100) on $(hostname)"
echo "CPUs: $SLURM_CPUS_PER_TASK  MEM: ${SLURM_MEM_PER_NODE:-$SLURM_MEM_PER_CPU}"

run_step () {
  local script="$1"
  echo "[$(date)] Running: $script"
  bash "$SCRIPTS_DIR/$script" || { echo "ERROR: $script failed"; exit 1; }
}

run_step combine_20_30.sh
run_step combine_20_30_40.sh
run_step combine_20_30_40_50.sh
run_step combine_20_30_40_50_60.sh
run_step combine_20_30_40_50_60_70.sh
run_step combine_20_30_40_50_60_70_80.sh
run_step combine_20_30_40_50_60_70_80_90.sh
run_step combine_20_30_40_50_60_70_80_90_100.sh

echo "[$(date)] Finished sequential combine jobs (20 → 100)"
