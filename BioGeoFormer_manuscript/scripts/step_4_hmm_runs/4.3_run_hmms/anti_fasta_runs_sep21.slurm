#!/bin/bash
#SBATCH --job-name=hmm_anti_split
#SBATCH --account=zoidberg
#SBATCH --partition=zoidberg
#SBATCH --qos=normal
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=24:00:00
#SBATCH --array=1-330%8
#SBATCH --output=/nfs5/MICRO/Thurber_Lab/jacob/hmm_runs_sep2/scripts/logs/hmm_anti_split_%A_%a.out
#SBATCH --error=/nfs5/MICRO/Thurber_Lab/jacob/hmm_runs_sep2/scripts/logs/hmm_anti_split_%A_%a.err
#SBATCH --mail-user=jacobwynne@ucsb.edu
#SBATCH --mail-type=FAIL,END

# Ensure logs directory exists
mkdir -p /nfs5/MICRO/Thurber_Lab/jacob/hmm_runs_sep2/scripts/logs

# Path to the file containing the 330 hmmsearch commands
CMD_FILE=/nfs5/MICRO/Thurber_Lab/jacob/hmm_runs_sep2/scripts/anti_fasta_runs_sep21.txt

# Extract the command for this array task
CMD=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $CMD_FILE)

# Skip if no command found
if [[ -z "$CMD" ]]; then
    echo "No command found for task ${SLURM_ARRAY_TASK_ID}, skipping."
    exit 0
fi

echo "Running task ${SLURM_ARRAY_TASK_ID}: $CMD"
bash -c "$CMD"
