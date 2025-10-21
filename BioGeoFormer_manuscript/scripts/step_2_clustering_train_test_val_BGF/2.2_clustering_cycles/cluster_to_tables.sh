#!/bin/bash

# Base directories
BASE_DIR="/nfs5/MICRO/Thurber_Lab/jacob/cycformer_datasplit_aug26"
OUTPUT_DIR="$BASE_DIR/output_tables"
SCRIPT="/local/cluster/cd-hit-v4.8.1-2019-0228/clstr2txt.pl"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Define the folders that now END at 100 for each starting tier
folders=(
  # 20→...→100
  "$BASE_DIR/split_data_20_30/split_data_20_30_40/split_data_20_30_40_50/split_data_20_30_40_50_60/split_data_20_30_40_50_60_70/split_data_20_30_40_50_60_70_80/split_data_20_30_40_50_60_70_80_90/split_data_20_30_40_50_60_70_80_90_100"

  # 30→...→100
  "$BASE_DIR/split_data_30_40/split_data_30_40_50/split_data_30_40_50_60/split_data_30_40_50_60_70/split_data_30_40_50_60_70_80/split_data_30_40_50_60_70_80_90/split_data_30_40_50_60_70_80_90_100"

  # 40→...→100
  "$BASE_DIR/split_data_40_50/split_data_40_50_60/split_data_40_50_60_70/split_data_40_50_60_70_80/split_data_40_50_60_70_80_90/split_data_40_50_60_70_80_90_100"

  # 50→...→100
  "$BASE_DIR/split_data_50_60/split_data_50_60_70/split_data_50_60_70_80/split_data_50_60_70_80_90/split_data_50_60_70_80_90_100"

  # 60→...→100
  "$BASE_DIR/split_data_60_70/split_data_60_70_80/split_data_60_70_80_90/split_data_60_70_80_90_100"

  # 70→...→100
  "$BASE_DIR/split_data_70_80/split_data_70_80_90/split_data_70_80_90_100"

  # 80→...→100
  "$BASE_DIR/split_data_80_90/split_data_80_90_100"

  # 90→100
  "$BASE_DIR/split_data_90_100"

  # direct 100%
  "$BASE_DIR/split_data_100"
)

# Decide the suffix (start tier) from the folder path
infer_suffix_from_folder() {
  local folder="$1"
  case "$folder" in
    *split_data_20_30*) echo "20" ;;
    *split_data_30_40*) echo "30" ;;
    *split_data_40_50*) echo "40" ;;
    *split_data_50_60*) echo "50" ;;
    *split_data_60_70*) echo "60" ;;
    *split_data_70_80*) echo "70" ;;
    *split_data_80_90*) echo "80" ;;
    *split_data_90_100*) echo "90" ;;
    *split_data_100) echo "100" ;;
    *) echo "UNK" ;;
  esac
}

# Process a folder and emit clstr2txt commands
process_folder() {
  local folder="$1"
  local suffix="$2"

  cd "$folder" || { echo "Failed to cd into $folder"; exit 1; }

  # Determine file pattern:
  # - If it's *split_data_100 (single dir), expect *_c100.faa.clstr
  # - Else (combined chains ending at 100), expect *_from..._100.clstr
  if [[ "$folder" == *"/split_data_100" ]]; then
    files=$(find "$folder" -maxdepth 1 -type f -name "*_c100.faa.clstr")
  else
    files=$(find "$folder" -maxdepth 1 -type f -name "*_from*_100.clstr")
  fi

  for file in $files; do
    [[ -f "$file" ]] || { echo "File not found: $file"; continue; }

    base_name=$(basename "$file")

    if [[ "$folder" == *"/split_data_100" ]]; then
      # Direct 100%: strip `_c100...`
      out="${base_name%%_c100*}_${suffix}.txt"
    else
      # Combined chain: strip `_from...`
      out="${base_name%%_from*}_${suffix}.txt"
    fi

    # Print the command (change 'echo' to 'eval' to actually run)
    echo "$SCRIPT \"$file\" > \"$OUTPUT_DIR/$out\""
  done
}

# Loop through each folder
for folder in "${folders[@]}"; do
  if [[ -d "$folder" ]]; then
    suffix=$(infer_suffix_from_folder "$folder")
    if [[ "$suffix" == "UNK" ]]; then
      echo "Warning: Could not infer suffix for $folder"
      continue
    fi
    process_folder "$folder" "$suffix"
  else
    echo "Directory not found: $folder"
  fi
done
