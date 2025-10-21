#!/bin/bash
#SBATCH --job-name=combine_90_100
#SBATCH --account=micro
#SBATCH --qos=normal
#SBATCH --partition=micro            # change if using a different partition
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --output=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/combine_90_100_%j.out
#SBATCH --error=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/combine_90_100_%j.err
#SBATCH --mail-user=jacobwynne@ucsb.edu
#SBATCH --mail-type=BEGIN,END,FAIL

SCRIPTS_DIR=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts
mkdir -p "$SCRIPTS_DIR/logs"

echo "[$(date)] Starting combine_90_100 on $(hostname)"
echo "CPUs: $SLURM_CPUS_PER_TASK  MEM: ${SLURM_MEM_PER_NODE:-$SLURM_MEM_PER_CPU}"

bash "$SCRIPTS_DIR/combine_90_100.sh" || { echo "combine_90_100.sh failed"; exit 1; }

echo "[$(date)] Finished combine_90_100"
