#!/bin/bash
#SBATCH --job-name=def_soy
#SBATCH --error=/nfs/datadrivendroughteffect-data/data_driven_drought/sbatch_logs/deficit_soy_mask.err
#SBATCH --output=/nfs/datadrivendroughteffect-data/data_driven_drought/sbatch_logs/deficit_soy_mask.out
#SBATCH --nodes=1
#SBATCH -p sesync

cd /nfs/datadrivendroughteffect-data/data_driven_drought/danielle/ 
R CMD BATCH --vanilla PRISM_masking_soy_deficit.R R_out/PRISM_masking_soy_deficit.Rout

