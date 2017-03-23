#!/bin/bash
#SBATCH --job-name=ppt_wheat
#SBATCH --error=/nfs/datadrivendroughteffect-data/data_driven_drought/sbatch_logs/ppt_wheat_weekly.err
#SBATCH --output=/nfs/datadrivendroughteffect-data/data_driven_drought/sbatch_logs/ppt_wheat_weekly.out
#SBATCH --nodes=1
#SBATCH -p sesync

cd /nfs/datadrivendroughteffect-data/data_driven_drought/danielle/ 
R CMD BATCH --vanilla PRISM_masking_weekly_wheat_ppt.R R_out/PRISM_masking_weekly_wheat_ppt.Rout

