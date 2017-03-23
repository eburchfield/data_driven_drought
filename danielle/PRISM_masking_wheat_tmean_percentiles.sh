#!/bin/bash
#SBATCH --job-name=T_wheat_perc
#SBATCH --error=/nfs/datadrivendroughteffect-data/data_driven_drought/sbatch_logs/tmean_perc_wheat_mask.err
#SBATCH --output=/nfs/datadrivendroughteffect-data/data_driven_drought/sbatch_logs/tmean_perc_wheat_mask.out
#SBATCH --nodes=1
#SBATCH -p sesync

cd /nfs/datadrivendroughteffect-data/data_driven_drought/danielle/ 
R CMD BATCH --vanilla PRISM_masking_wheat_tmean_percentiles.R R_out/PRISM_masking_wheat_tmean_percentiles.Rout

