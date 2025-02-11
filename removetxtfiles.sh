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

# Make a base directory to put all the txt files folders
TXT_BASE_DIR=${IN_DIR}_txtfiles
echo "Creating base txt files directory at $TXT_BASE_DIR"

mkdir -p $TXT_BASE_DIR

# Process each subfolder
for SUB_DIR in $(find $IN_DIR -mindepth 1 -maxdepth 1 -type d); do
  SUB_DIR_NAME=$(basename $SUB_DIR)
  TXT_DIR=${TXT_BASE_DIR}/${SUB_DIR_NAME}_txtfiles

  echo "Processing folder $SUB_DIR"
  echo "Creating txt files directory for $SUB_DIR_NAME at $TXT_DIR"

  mkdir -p $TXT_DIR

  # Move all .txt files into the txt file folder
  find $SUB_DIR -type f -name "*.txt" -exec mv {} $TXT_DIR \;

  echo "Done moving files for $SUB_DIR_NAME. Files moved to $TXT_DIR:"
  ls -lh $TXT_DIR
done

echo "All done."
