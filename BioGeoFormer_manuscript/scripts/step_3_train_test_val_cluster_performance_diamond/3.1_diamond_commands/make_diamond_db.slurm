#!/bin/bash
#SBATCH --job-name=diamond_makedb
#SBATCH --account=zoidberg
#SBATCH --qos=normal
#SBATCH --partition=zoidberg
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=12:00:00
#SBATCH --array=1-330%100
#SBATCH --output=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/diamond_makedb_%A_%a.out
#SBATCH --error=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/logs/diamond_makedb_%A_%a.err
#SBATCH --mail-user=jacobwynne@ucsb.edu
#SBATCH --mail-type=END,FAIL

# Load DIAMOND if needed
# module load diamond/2.x

CMD_FILE=/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/make_diamond_db.txt

# Extract the command for this array index
CMD=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $CMD_FILE)

echo "[$(date)] Running task ${SLURM_ARRAY_TASK_ID}: $CMD"
eval $CMD
