#!/bin/bash
#SBATCH --job-name=P_ag_perc
#SBATCH --error=/nfs/datadrivendroughteffect-data/data_driven_drought/sbatch_logs/ppt_perc_ag_mask.err
#SBATCH --output=/nfs/datadrivendroughteffect-data/data_driven_drought/sbatch_logs/ppt_perc_ag_mask.out
#SBATCH --nodes=1
#SBATCH -p sesync

cd /nfs/datadrivendroughteffect-data/data_driven_drought/danielle/ 
R CMD BATCH --vanilla PRISM_masking_ag_ppt_percentiles.R R_out/PRISM_masking_ag_ppt_percentiles.Rout

