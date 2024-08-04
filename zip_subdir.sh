#!/bin/bash
#SBATCH --job-name=zip_subdir
#SBATCH --mail-user=danwatson@vt.edu
#SBATCH --mail-type=BEGIN,FAIL,END
#SBATCH --output=/projects/birdnet/chemours/zipSubdirectory_%j.log
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=2-00:00:00
#SBATCH --account="birdnet"
##SBATCH --partition="normal_q"

# Define the directory to be zipped and the output zip file name
TARGET_DIR="/projects/birdnet/chemours/Data_2024_bn_out"
ZIP_FILE="/projects/birdnet/chemours/Data_2024_bn_out.zip"

# Change to the target directory
cd $TARGET_DIR
if [ $? -ne 0 ]; then
  echo "Failed to change directory to $TARGET_DIR"
  exit 1
fi
echo "Changed directory to: $(pwd)"

# Zip the contents of the target directory
zip -r $ZIP_FILE .
if [ $? -ne 0 ]; then
  echo "Failed to zip the contents of $TARGET_DIR"
  exit 1
fi
echo "Successfully zipped the contents of $TARGET_DIR into $ZIP_FILE"

# Print end of script debugging information
echo "All done"
