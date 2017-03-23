#!/bin/bash
#SBATCH --job-name=sddi_ag
#SBATCH --error=/nfs/datadrivendroughteffect-data/data_driven_drought/sbatch_logs/sddi_ag_mask.err
#SBATCH --output=/nfs/datadrivendroughteffect-data/data_driven_drought/sbatch_logs/sddi_ag_mask.out
#SBATCH --nodes=1
#SBATCH -p sesync

cd /nfs/datadrivendroughteffect-data/data_driven_drought/danielle/ 
R CMD BATCH --vanilla PRISM_masking_ag_sddi.R R_out/PRISM_masking_ag_sddi.Rout

