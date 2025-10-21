#!/bin/bash
#SBATCH --job-name=combine_40_50_60_70_80_90_100
#SBATCH --account=micro
#SBATCH --qos=normal
#SBATCH --partition=micro
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=24:00:00
#SBATCH --output=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/combine_40_50_60_70_80_90_100_%j.out
#SBATCH --error=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/combine_40_50_60_70_80_90_100_%j.err
#SBATCH --mail-user=jacobwynne@ucsb.edu
#SBATCH --mail-type=BEGIN,END,FAIL

SCRIPT=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/combine_40_50_60_70_80_90_100.sh

echo "[$(date)] Starting combine_40_50_60_70_80_90_100 job"
bash $SCRIPT
echo "[$(date)] Finished combine_40_50_60_70_80_90_100 job"

