#!/bin/bash
#
#SBATCH --array=0-9
#SBATCH --job-name=slr7749
#SBATCH --output=slurm_%a.out

#SBATCH --partition=sesync
/usr/lib/R/bin/Rscript --vanilla slurm_run.R
