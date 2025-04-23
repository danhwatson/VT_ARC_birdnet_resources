#!/bin/bash
#SBATCH --job-name=bn_check_species_list_w4
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=1  
#SBATCH --partition=intel_q
#SBATCH --account=birdnet
#SBATCH --time=0-00:30:00
#SBATCH --output=/projects/birdnet/chemours/birdnet_job_output/%x_%j.out

# Load pre-requisite module
module load site/tinkercliffs/easybuild/setup

# Load Miniconda3 module
module load Miniconda3/23.10.0-1

# Export the path for the conda environment that contains BirdNET-Analyzer v2.4
export BNENV=/projects/birdnet/env/tc/bna2.4-intel

# Activate the conda environment
source activate $BNENV

# Output directory for species list
SPECIES_LIST_DIR=/projects/birdnet/chemours/species_lists_check
mkdir -p $SPECIES_LIST_DIR

# Generate species list for week 15
# Newport VA for NSWO project

python $BNENV/BirdNET-Analyzer/species.py \
  --lat 37.4121 --lon -80.5227 --week 15 \
  --sortby alpha \
  --o $SPECIES_LIST_DIR/species_list_week15_newport.txt

# Deactivate environment
conda deactivate