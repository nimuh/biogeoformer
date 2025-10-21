#!/bin/bash
#SBATCH --job-name=diamond_blastp
#SBATCH --account=zoidberg
#SBATCH --qos=normal
#SBATCH --partition=zoidberg
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --array=1-660%25
#SBATCH --output=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/diamond_blastp_%A_%a.out
#SBATCH --error=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/diamond_blastp_%A_%a.err
#SBATCH --mail-user=jacobwynne@ucsb.edu
#SBATCH --mail-type=END,FAIL

# Load DIAMOND if needed
# module load diamond/2.x

CMD_FILE=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/run_diamond.txt

# Extract the command for this array index
CMD=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $CMD_FILE)

echo "[$(date)] Running job ${SLURM_ARRAY_TASK_ID} of 660: $CMD"
eval $CMD
