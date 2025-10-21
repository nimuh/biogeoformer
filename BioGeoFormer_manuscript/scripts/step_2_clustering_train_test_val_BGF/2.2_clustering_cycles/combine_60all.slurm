#!/bin/bash
#SBATCH --job-name=combine_chain_60_to_100
#SBATCH --account=micro
#SBATCH --qos=normal
#SBATCH --partition=micro           # change if you’ll run elsewhere
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=48:00:00
#SBATCH --output=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/combine_chain_60_to_100_%j.out
#SBATCH --error=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/combine_chain_60_to_100_%j.err
#SBATCH --mail-user=jacobwynne@ucsb.edu
#SBATCH --mail-type=BEGIN,END,FAIL

SCRIPTS_DIR=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts
mkdir -p "$SCRIPTS_DIR/logs"

echo "[$(date)] Starting sequential combine jobs (60 → 100) on $(hostname)"
echo "Using $SLURM_CPUS_PER_TASK CPUs and ${SLURM_MEM_PER_NODE:-$SLURM_MEM_PER_CPU} memory"

# 60→70
bash "$SCRIPTS_DIR/combine_60_70.sh" || { echo "combine_60_70.sh failed"; exit 1; }
# 60→70→80
bash "$SCRIPTS_DIR/combine_60_70_80.sh" || { echo "combine_60_70_80.sh failed"; exit 1; }
# 60→70→80→90
bash "$SCRIPTS_DIR/combine_60_70_80_90.sh" || { echo "combine_60_70_80_90.sh failed"; exit 1; }
# 60→70→80→90→100
bash "$SCRIPTS_DIR/combine_60_70_80_90_100.sh" || { echo "combine_60_70_80_90_100.sh failed"; exit 1; }

echo "[$(date)] Finished sequential combine jobs (60 → 100)"
