#!/bin/bash
#SBATCH --account=birdnet 
#SBATCH --partition=t4_normal_q 
#SBATCH --nodes=1 
#SBATCH --ntasks=1 
#SBATCH --cpus-per-task=1 
#SBATCH --gres=gpu:1 
#SBATCH --time=05:00:00 
#SBATCH --output=/projects/birdnet/Chemours/myfinds_%j.out

# Specify the input folder to process
IN_DIR=/projects/birdnet/Chemours/Data_2023

# Specify the minimum and maximum file sizes in megabytes to extract
MIN_FILE_SIZE_MB=230
MAX_FILE_SIZE_MB=235

# Make a directory to put the matching files in
MATCHING_DIR=${IN_DIR}_twentythreeminfiles
echo "Moving files of size between ${MIN_FILE_SIZE_MB}MB and ${MAX_FILE_SIZE_MB}MB to $MATCHING_DIR"

cd $IN_DIR
cd ..
mkdir $MATCHING_DIR

cd $IN_DIR
# Use find to output a list of file paths, and pipe the output to xargs to execute the mv command in parallel
find . -maxdepth 1 -size +"${MIN_FILE_SIZE_MB}"M -size -"${MAX_FILE_SIZE_MB}"M -print0 | xargs -0 -P 8 -I {} mv {} $MATCHING_DIR

echo "Done moving the following files:"
ls -lh $MATCHING_DIR