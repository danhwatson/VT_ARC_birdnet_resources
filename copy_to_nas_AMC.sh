#!/bin/bash
#SBATCH --job-name=copyNAS
#SBATCH --output=/projects/birdnet/AMC_Quail/copyNAS_%j.log
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
## cd to path to the containing directory
cd /projects/birdnet/AMC_Quail 

#start transfer
rclone copy remote4NAS:HunterLab/Elizabeth_Hunter/Data /projects/birdnet/AMC_Quail/New_Folder

echo "All done"