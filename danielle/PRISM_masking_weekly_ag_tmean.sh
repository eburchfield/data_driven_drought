#!/bin/bash
#SBATCH --job-name=tmean_ag
#SBATCH --error=/nfs/datadrivendroughteffect-data/data_driven_drought/sbatch_logs/tmean_ag_weekly.err
#SBATCH --output=/nfs/datadrivendroughteffect-data/data_driven_drought/sbatch_logs/tmean_ag_weekly.out
#SBATCH --nodes=1
#SBATCH -p sesync

cd /nfs/datadrivendroughteffect-data/data_driven_drought/danielle/ 
R CMD BATCH --vanilla PRISM_masking_weekly_ag_tmean.R R_out/PRISM_masking_weekly_ag_tmean.Rout

