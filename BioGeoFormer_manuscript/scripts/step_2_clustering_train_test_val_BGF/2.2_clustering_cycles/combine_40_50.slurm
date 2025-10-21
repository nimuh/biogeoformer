#!/bin/bash
#SBATCH --job-name=combine_40_50
#SBATCH --account=micro          # <-- change to your account if needed
#SBATCH --qos=normal
#SBATCH --partition=micro        # <-- change to a valid partition
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --output=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/combine_40_50_%j.out
#SBATCH --error=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/combine_40_50_%j.err
#SBATCH --mail-user=jacobwynne@ucsb.edu
#SBATCH --mail-type=BEGIN,END,FAIL

# Load any modules if needed (uncomment if your cluster requires it)
# module load cd-hit

# Path to your actual script
SCRIPT=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/combine_40_50.sh

echo "[$(date)] Starting combine_40_50 job on $SLURM_CPUS_PER_TASK CPUs and $SLURM_MEM_PER_NODE memory"
bash $SCRIPT
echo "[$(date)] Finished combine_40_50 job"
