#!/bin/bash
#SBATCH --job-name=segments_bn
#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH --partition=intel_q
#SBATCH --account=birdnet
#SBATCH --time=4-00:00:00
#SBATCH --output=/projects/birdnet/chemours/bn_segments_output/%x_%j.out

# Load pre-requisite module
module load site/tinkercliffs/easybuild/setup

# Load Miniconda3 module
module load Miniconda3/23.10.0-1

# Export the path for the conda environment that contains the updated BirdNET-Analyzer
export BNENV=/projects/birdnet/env/tc/bna2.4-intel

# Activate the conda environment
source activate $BNENV

# Ensure necessary packages are installed
conda install -y numpy tensorflow librosa resampy 

# Set directories for input and output in a /projects/birdnet/ directory
IN_DIR=/projects/birdnet/chemours/data_2024/ # Where the recordings (.wav, .flac, .mp3) are located
OUT_DIR=/projects/birdnet/chemours/data_2024_bn/ # Where bn output is 
SEG_DIR=/projects/birdnet/chemours/data_2024_bn_segments/ 

# Run segments
date
python $BNENV/BirdNET-Analyzer/segments.py --audio $IN_DIR --results $OUT_DIR --o $SEG_DIR  --min_conf 0.95 --max_segments 12 --seg_length 3.0 --threads 48
date 

# Deactivate the environment
conda deactivate

echo "All done"