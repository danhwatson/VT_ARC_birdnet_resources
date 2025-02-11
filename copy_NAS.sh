#!/bin/bash
#SBATCH --job-name=copyNASv3
#SBATCH --mail-user=danwatson@vt.edu
#SBATCH --mail-type=BEGIN,FAIL,END
#SBATCH --output=/projects/birdnet/chemours/copyNASv3_%j.log
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=2-00:00:00
#SBATCH --account="birdnet"
##SBATCH --partition="normal_q"


if [ -z ${HOME+x} ]; then
  export HOME=$(echo ~)
  source /etc/profile
  source /etc/bashrc
  source $HOME/.bashrc
fi

## load rclone
module load rclone/1.60.0
echo "rclone module loaded"

## cd to path to the containing directory
cd /projects/birdnet/chemours/data_2024_bn_out
echo "Changed directory to: $(pwd)"

## start transfer
rclone copy /projects/birdnet/chemours/data_2024_bn_out remote4NAS:HunterLab/Dan_W/data_2024_out
echo "rclone copy command executed"

# Print end of script debugging information
echo "Script finished at: $(date)"
