#!/bin/bash
#SBATCH --job-name=m_frac_tmean
#SBATCH --error=/nfs/datadrivendroughteffect-data/data_driven_drought/sbatch_logs/tmean_maize_frac.err
#SBATCH --output=/nfs/datadrivendroughteffect-data/data_driven_drought/sbatch_logs/tmean_maize_frac.out
#SBATCH --nodes=1
#SBATCH -p sesync

cd /nfs/datadrivendroughteffect-data/data_driven_drought/danielle/ 
R CMD BATCH --vanilla PRISM_masking_maize_frac_tmean.R R_out/PRISM_masking_maize_frac_tmean.Rout

