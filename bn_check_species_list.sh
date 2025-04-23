#!/bin/bash
#SBATCH --job-name=bn_check_species_list_w1
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=1  
#SBATCH --partition=intel_q
#SBATCH --account=birdnet
#SBATCH --time=0-00:30:00
#SBATCH --output=/projects/birdnet/JH_NSWO/birdnet_job_output/%x_%j.out

# Load pre-requisite module
module load site/tinkercliffs/easybuild/setup

# Load Miniconda3 module
module load Miniconda3/23.10.0-1

# Export the path for the conda environment that contains BirdNET-Analyzer v2.4
export BNENV=/projects/birdnet/env/tc/bna2.4-intel

# Activate the conda environment
source activate $BNENV

# Output directory for species list
SPECIES_LIST_DIR=/projects/birdnet/JH_NSWO/species_lists
mkdir -p $SPECIES_LIST_DIR

# Generate species list for Week 1
python $BNENV/BirdNET-Analyzer/get_species_list.py \
    --lat 37.4121 --lon -80.5227 --week 1 \
    > $SPECIES_LIST_DIR/species_list_week1.txt

# Deactivate the environment
conda deactivate
