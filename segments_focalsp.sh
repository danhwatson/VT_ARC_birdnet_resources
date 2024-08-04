#!/bin/bash
#SBATCH --account=birdnet 
#SBATCH --partition=t4_normal_q 
#SBATCH --nodes=1 
#SBATCH --ntasks=1 
#SBATCH --cpus-per-task=1 
#SBATCH --gres=gpu:1 
#SBATCH --time=2-00:00:00 
#SBATCH --output=/projects/birdnet/chemours/extract_focalsp_%j.out

# Define the base directory
BASE_DIR="/projects/birdnet/chemours/Data_2024_bn_segments"

# Define the output base directory
OUTPUT_BASE_DIR="/projects/birdnet/chemours/extracted_bacs"

# Define the species identifier
SPECIES="bacspa"

# Create the output base directory if it doesn't exist
mkdir -p $OUTPUT_BASE_DIR

# Loop through each segment directory
for SEGMENT_DIR in ${BASE_DIR}/segments_*; do
  # Check if the directory exists
  if [ -d "$SEGMENT_DIR" ]; then
    echo "Processing directory: $SEGMENT_DIR"
    
    # Extract the segment name
    SEGMENT_NAME=$(basename $SEGMENT_DIR)
    
    # Define the output directory for the extracted files
    OUTPUT_DIR="${OUTPUT_BASE_DIR}/${SEGMENT_NAME}"
    mkdir -p $OUTPUT_DIR
    
    # Loop through each .wav file in the species subdirectory
    for WAV_FILE in ${SEGMENT_DIR}/${SPECIES}/*.wav; do
      # Check if the .wav file exists
      if [ -f "$WAV_FILE" ]; then
        echo "Extracting from file: $WAV_FILE"
        
        # Copy the file to the output directory
        cp $WAV_FILE $OUTPUT_DIR/
      else
        echo "No .wav files found for $SPECIES in $SEGMENT_DIR"
      fi
    done
  else
    echo "Directory $SEGMENT_DIR does not exist"
  fi
done

echo "Extraction complete."