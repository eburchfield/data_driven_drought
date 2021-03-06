#!/bin/bash
#SBATCH --job-name=ppt3_wheat
#SBATCH --error=/nfs/datadrivendroughteffect-data/data_driven_drought/sbatch_logs/ppt3_wheat_mask.err
#SBATCH --output=/nfs/datadrivendroughteffect-data/data_driven_drought/sbatch_logs/ppt3_wheat_mask.out
#SBATCH --nodes=1
#SBATCH -p sesync

cd /nfs/datadrivendroughteffect-data/data_driven_drought/danielle/ 
R CMD BATCH --vanilla PRISM_masking_wheat_ppt_sq.R R_out/PRISM_masking_wheat_ppt_sq.Rout

