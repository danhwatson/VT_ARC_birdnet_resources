#!/bin/bash
#SBATCH --account=birdnet 
#SBATCH --partition=t4_normal_q 
#SBATCH --nodes=1 
#SBATCH --ntasks=32 
#SBATCH --cpus-per-task=1 
#SBATCH --gres=gpu:1 
#SBATCH --time=70:00:00 

module reset 
module load BirdNET/20201214-fosscuda-2019b-Python-3.7.4 

#Set variables uppress some warning messages: 
export OMPI_MCA_mpi_warn_on_fork=0 
export OMPI_MCA_btl_openib_if_exclude=mlx5_1 

#Change to directory from which job was submitted 
cd $SLURM_SUBMIT_DIR 

#Set variables defining the analysis: 
BN_BIN=/apps/easybuild/software/infer-skylake/BirdNET/20201214-fosscuda-2019b-Python-3.7.4/analyze.py 
#IN_DIR=/home/ehunter1/bn_arc/input/Vya_Perm_2018
IN_DIR=/projects/birdnet/test/data_2023_06
#OUT_DIR=/home/ehunter1/bn_arc/output/Output_Vya_Perm_2018
OUT_DIR=/projects/birdnet/test/data_2023_06_output

#Run the analysis 
echo "`date` Starting Birdnet..." 
python $BN_BIN --i $IN_DIR --o $OUT_DIR --lat 31.0429 --lon -81.9687  #edit with the rough coordinates of where your acoustic files were recorded
echo "`date` Done processing $IN_DIR"
