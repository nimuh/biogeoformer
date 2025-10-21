#!/bin/bash
#SBATCH --job-name=combine_40_50_60_70
#SBATCH --account=micro          # <-- adjust if your cluster requires a different account
#SBATCH --qos=normal
#SBATCH --partition=micro        # <-- adjust to the correct partition on your system
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=24:00:00
#SBATCH --output=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/combine_40_50_60_70_%j.out
#SBATCH --error=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/combine_40_50_60_70_%j.err
#SBATCH --mail-user=jacobwynne@ucsb.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# Path to your script
SCRIPT=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/combine_40_50_60_70.sh

echo "[$(date)] Starting combine_40_50_60_70 job on $SLURM_CPUS_PER_TASK CPUs and $SLURM_MEM_PER_NODE memory"
bash $SCRIPT
echo "[$(date)] Finished combine_40_50_60_70 job"
