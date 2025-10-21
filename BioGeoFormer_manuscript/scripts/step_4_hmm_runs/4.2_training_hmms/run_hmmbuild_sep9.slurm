#!/bin/bash
#SBATCH --job-name=hmmbuild_array
#SBATCH --account=micro
#SBATCH --qos=normal
#SBATCH --partition=micro
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=24:00:00
#SBATCH --array=1-330%8
#SBATCH --output=logs/hmmbuild_%A_%a.out
#SBATCH --error=logs/hmmbuild_%A_%a.err
#SBATCH --mail-user=jacobwynne@ucsb.edu
#SBATCH --mail-type=FAIL,END

# Make sure logs directory exists
mkdir -p logs

# Select the command from the text file based on array index
CMD=$(sed -n "${SLURM_ARRAY_TASK_ID}p" run_hmmbuild_aug26.txt)

echo "Running task $SLURM_ARRAY_TASK_ID: $CMD"
eval "$CMD"
