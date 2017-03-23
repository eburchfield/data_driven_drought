#!/bin/bash
#SBATCH --job-name=sddi3_soy
#SBATCH --error=/nfs/datadrivendroughteffect-data/data_driven_drought/sbatch_logs/sddi3_soy_mask.err
#SBATCH --output=/nfs/datadrivendroughteffect-data/data_driven_drought/sbatch_logs/sddi3_soy_mask.out
#SBATCH --nodes=1
#SBATCH -p sesync

cd /nfs/datadrivendroughteffect-data/data_driven_drought/danielle/ 
R CMD BATCH --vanilla PRISM_masking_soy_sddi_sq.R R_out/PRISM_masking_soy_sddi_sq.Rout

