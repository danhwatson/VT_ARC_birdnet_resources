#!/bin/bash
#SBATCH --account=birdnet 
#SBATCH --partition=t4_normal_q 
#SBATCH --nodes=1 
#SBATCH --ntasks=1 
#SBATCH --cpus-per-task=1 
#SBATCH --gres=gpu:1 
#SBATCH --time=2-00:00:00 
#SBATCH --output=/projects/birdnet/chemours/myfinds_%j.out

#specify the input folder to process
IN_DIR=/projects/birdnet/chemours/data_2024

#make a directory to put the small files in
SMALL_DIR=${IN_DIR}_smallfiles
echo "moving files to $SMALL_DIR"

cd $IN_DIR
cd ..
mkdir $SMALL_DIR

cd $IN_DIR
#move all files smaller than 5mb (~30 seconds) into the small file folder
find . -maxdepth 1 -size -5M -exec mv {} $SMALL_DIR \;

echo "done moving the following files:"
ls -lh $SMALL_DIR


