#!/bin/bash
#SBATCH --job-name=combine_chain_50_to_100
#SBATCH --account=micro
#SBATCH --qos=normal
#SBATCH --partition=micro
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=72:00:00
#SBATCH --output=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/combine_chain_50_to_100_%j.out
#SBATCH --error=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/combine_chain_50_to_100_%j.err
#SBATCH --mail-user=jacobwynne@ucsb.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# Path to your scripts
SCRIPTS_DIR=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts

# Ensure logs directory exists
mkdir -p $SCRIPTS_DIR/logs

echo "[$(date)] Starting sequential combine jobs (50 → 100) on $(hostname)"

bash $SCRIPTS_DIR/combine_50_60.sh                 || { echo "combine_50_60.sh failed"; exit 1; }
bash $SCRIPTS_DIR/combine_50_60_70.sh              || { echo "combine_50_60_70.sh failed"; exit 1; }
bash $SCRIPTS_DIR/combine_50_60_70_80.sh           || { echo "combine_50_60_70_80.sh failed"; exit 1; }
bash $SCRIPTS_DIR/combine_50_60_70_80_90.sh        || { echo "combine_50_60_70_80_90.sh failed"; exit 1; }
bash $SCRIPTS_DIR/combine_50_60_70_80_90_100.sh    || { echo "combine_50_60_70_80_90_100.sh failed"; exit 1; }

echo "[$(date)] Finished sequential combine jobs (50 → 100)"
