#!/bin/bash
#SBATCH --job-name=def3_eco
#SBATCH --error=/nfs/datadrivendroughteffect-data/data_driven_drought/sbatch_logs/def3_eco_mask.err
#SBATCH --output=/nfs/datadrivendroughteffect-data/data_driven_drought/sbatch_logs/def3_eco_mask.out
#SBATCH --nodes=1
#SBATCH -p sesync

cd /nfs/datadrivendroughteffect-data/data_driven_drought/danielle/ 
R CMD BATCH --vanilla PRISM_masking_eco_deficit_sq.R R_out/PRISM_masking_eco_deficit_sq.Rout

