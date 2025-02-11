#!/bin/bash
#SBATCH --account=birdnet 
#SBATCH --partition=t4_normal_q 
#SBATCH --nodes=1 
#SBATCH --ntasks=1 
#SBATCH --cpus-per-task=1 
#SBATCH --gres=gpu:1 
#SBATCH --time=2-00:00:00 
#SBATCH --output=/projects/birdnet/chemours/combine_directories_%j.out

# Specify the source directories and target directory
SRC_DIR1=/projects/birdnet/chemours/data_2024_07
SRC_DIR2=/projects/birdnet/chemours/data_2024_09
TARGET_DIR=/projects/birdnet/chemours/data_2024

# Ensure target directory exists
mkdir -p $TARGET_DIR

echo "Combining files from $SRC_DIR1 and $SRC_DIR2 into $TARGET_DIR"

# Move only files (not directories) from the first source directory
echo "Moving files from $SRC_DIR1"
find $SRC_DIR1 -type f -exec mv {} $TARGET_DIR/ \;
echo "Done moving files from $SRC_DIR1"

# Move only files (not directories) from the second source directory
echo "Moving files from $SRC_DIR2"
find $SRC_DIR2 -type f -exec mv {} $TARGET_DIR/ \;
echo "Done moving files from $SRC_DIR2"

echo "All files have been combined into $TARGET_DIR"
echo "Script execution completed."/HunterLab/Dan_W/data_2024_07/Data_2024/SMA10415_Data,0,1720115802065