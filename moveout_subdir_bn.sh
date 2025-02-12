#!/bin/bash
#SBATCH --account=birdnet 
#SBATCH --partition=t4_normal_q 
#SBATCH --nodes=1 
#SBATCH --ntasks=1 
#SBATCH --cpus-per-task=1 
#SBATCH --gres=gpu:1 
#SBATCH --time=2-00:00:00 
#SBATCH --output=/projects/birdnet/chemours/myfinds_%j.out

# For moving audio or BirdNET .txt files from subdirectories to a single directory
# Specify the input directory/folder to process (this one directory will contain the subdirectories inside it)
IN_DIR=/projects/birdnet/chemours/data_2024

echo "Processing subdirectories in $IN_DIR"

# Process each subfolder
for SUB_DIR in $(find $IN_DIR -mindepth 1 -maxdepth 1 -type d); do
  echo "Processing folder $SUB_DIR"

  # Move all files from the subdirectory to the main directory
  find $SUB_DIR -type f -exec mv {} $IN_DIR \;

  echo "Done moving files from $SUB_DIR"
done

# Delete empty subdirectories now that files have been moved
echo "Deleting empty folders from $IN_DIR"

# Delete empty subdirectories to clean up the directory 
find $IN_DIR -type d -empty -delete

echo "Deletion of empty subdirectories completed."

echo "All done"
