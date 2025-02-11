#!/bin/bash
#SBATCH --account=birdnet 
#SBATCH --partition=t4_normal_q 
#SBATCH --nodes=1 
#SBATCH --ntasks=1 
#SBATCH --cpus-per-task=1 
#SBATCH --time=2-00:00:00 
#SBATCH --output=/projects/birdnet/chemours/select_files_%j.out

# Source directory containing files
SRC_DIR=/projects/birdnet/chemours/data_2023
# Target directory for selected files
TARGET_DIR=/projects/birdnet/chemours/data_before_20230515

# Ensure the target directory exists
mkdir -p $TARGET_DIR

# Date cutoff in YYYYMMDD format
CUTOFF_DATE=20230514

echo "Selecting files on or before $CUTOFF_DATE from $SRC_DIR"

# Loop through files in the source directory
for FILE in "$SRC_DIR"/*; do
  # Extract the date from the filename using pattern matching
  FILENAME=$(basename "$FILE")
  if [[ "$FILENAME" =~ _([0-9]{8})_ ]]; then
    FILE_DATE=${BASH_REMATCH[1]} # Extract YYYYMMDD part

    # Compare the file date to the cutoff date
    if [[ $FILE_DATE -le $CUTOFF_DATE ]]; then
      echo "Copying $FILE to $TARGET_DIR"
      mv "$FILE" "$TARGET_DIR/"
    fi
  else
    echo "Skipping $FILE (no valid date found in filename)"
  fi
done

echo "File selection completed. Files moved to $TARGET_DIR."