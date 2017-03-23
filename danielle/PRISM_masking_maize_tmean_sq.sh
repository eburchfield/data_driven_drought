#!/bin/bash
#SBATCH --job-name=tmean3_maize
#SBATCH --error=/nfs/datadrivendroughteffect-data/data_driven_drought/sbatch_logs/tmean3_maize_mask.err
#SBATCH --output=/nfs/datadrivendroughteffect-data/data_driven_drought/sbatch_logs/tmean3_maize_mask.out
#SBATCH --nodes=1
#SBATCH -p sesync

cd /nfs/datadrivendroughteffect-data/data_driven_drought/danielle/ 
R CMD BATCH --vanilla PRISM_masking_maize_tmean_sq.R R_out/PRISM_masking_maize_tmean_sq.Rout

