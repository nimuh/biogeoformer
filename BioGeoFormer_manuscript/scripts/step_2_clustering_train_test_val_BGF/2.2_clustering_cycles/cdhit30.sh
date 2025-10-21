#!/bin/bash
set -euo pipefail

# Inputs/outputs
input_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_40"
output_dir="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/split_data_30"
jobfile="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26/scripts/cdhit30.txt"

# psi-cd-hit.pl path
psi_cd_hit_path="/local/cluster/cd-hit-v4.8.1-2019-0228/psi-cd-hit/psi-cd-hit.pl"

# Parallelism for psi-cd-hit (para * blp ~= total cores per job)
PARA=4     # number of parallel BLAST jobs
BLP=4      # threads per BLAST job  (4*4 = 16 cores)

mkdir -p "$output_dir"
mkdir -p "$(dirname "$jobfile")"

# Empty the jobfile before writing
: > "$jobfile"

# Emit one psi-cd-hit command per input FASTA
for file in "$input_dir"/*.faa; do
  filename=$(basename "$file")
  # turn foo_c40.faa -> foo_c30.faa
  output_filename="${filename%_c40.faa}_c30.faa"
  output_file="${output_dir}/${output_filename}"

  # Keep quotes because some filenames may contain commas/characters that need quoting
  echo "$psi_cd_hit_path -i \"$file\" -o \"$output_file\" -c 0.3 -para $PARA -blp $BLP" >> "$jobfile"
done

echo "Wrote $(wc -l < "$jobfile") commands to $jobfile"
