#!/bin/bash
#SBATCH --account=birdnet 
#SBATCH --partition=t4_normal_q 
#SBATCH --nodes=1 
#SBATCH --ntasks=1 
#SBATCH --cpus-per-task=1 
#SBATCH --gres=gpu:1 
#SBATCH --time=2-00:00:00 
#SBATCH --output=/projects/birdnet/chemours/myfinds_%j.out

# Specify the input folder to process
IN_DIR=/projects/birdnet/chemours/data_2024

# Make a base directory to put all the small files folders
SMALL_BASE_DIR=${IN_DIR}_smallfiles
echo "Creating base small files directory at $SMALL_BASE_DIR"

mkdir -p $SMALL_BASE_DIR

# Process each subfolder
for SUB_DIR in $(find $IN_DIR -mindepth 1 -maxdepth 1 -type d); do
  SUB_DIR_NAME=$(basename $SUB_DIR)
  SMALL_DIR=${SMALL_BASE_DIR}/${SUB_DIR_NAME}_smallfiles

  echo "Processing folder $SUB_DIR"
  echo "Creating small files directory for $SUB_DIR_NAME at $SMALL_DIR"

  mkdir -p $SMALL_DIR

  # Move all files smaller than 5MB (~30 seconds) into the small file folder
  find $SUB_DIR -type f -size -5M -exec mv {} $SMALL_DIR \;

  echo "Done moving files for $SUB_DIR_NAME. Files moved to $SMALL_DIR:"
  ls -lh $SMALL_DIR
done

echo "All done"

