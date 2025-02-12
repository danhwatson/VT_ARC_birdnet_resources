#!/bin/bash
#SBATCH --account=birdnet 
#SBATCH --partition=t4_normal_q 
#SBATCH --nodes=1 
#SBATCH --ntasks=1 
#SBATCH --cpus-per-task=1 
#SBATCH --gres=gpu:1 
#SBATCH --time=2-00:00:00 
#SBATCH --output=/projects/birdnet/chemours/myfinds_%j.out

# For putting audio or BirdNET .txt files back into subdirectories for organization
# Specify the input and output directories
IN_DIR=/projects/birdnet/chemours/data_2024
OUT_BASE_DIR=/projects/birdnet/chemours/data_2024

echo "Sorting files from $IN_DIR into subdirectories in $OUT_BASE_DIR"

# Process each file in the input directory
for FILE in $IN_DIR/*; do
  if [[ -f $FILE ]]; then
    # Extract the first 8 characters of the file name
    BASENAME=$(basename $FILE)
    PREFIX=${BASENAME:0:8}

    # Create the subdirectory if it doesn't exist
    SUB_DIR=${OUT_BASE_DIR}/${PREFIX}_Data
    mkdir -p $SUB_DIR

    # Move the file to the subdirectory
    mv $FILE $SUB_DIR

    echo "Moved $FILE to $SUB_DIR"
  fi
done

echo "All done"
