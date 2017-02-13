#devtools::install_github("sesync-ci/rslurm", ref="wait")
library(raster)
library(rslurm)
library(stringr)
library(ncdf4)
library(rslurm)

crops <- c("ag", "eco", "maize", "wheat", "soy")
outtmp <- '/nfs/scratch/ddde/'
dir.create(outtmp, showWarnings=FALSE)

# UPDATE FOR EACH DATASET
res <- "365"                # "weekly"
dname <- 'PRISM'            # "NARR", "NLDAS", 
outfn <- '/nfs/datadrivendroughteffect-data/Data/Masked_data/TMP_PRISM_annual_ppt'
dlist <- Sys.glob(paste0('/nfs/datadrivendroughteffect-data/Data/PRISM/PRISM_daily_ppt', '_', '*', '.nc'))

slurm_pars <- expand.grid(dname=dname, dfile=dlist,
                          res=res, crop=crops, stringsAsFactors=FALSE)
matrix_prep <- function(dname, dfile, res, crop) {
  
  # set thread-specific, local tmp dir for raster calculations
  raster_tmp <- paste0('/tmp/ddde_raster_', Sys.getpid())
  dir.create(raster_tmp)
  rasterOptions(tmpdir=raster_tmp)
  
  # aquire mask
  mask <- brick(paste0('/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/',
                       dname, '_', res, '_', crop, '_frac.nc'))
  
  # aquire annual brick
  year <- brick(dfile)
  
  # extract name of future layer
  lname <- str_extract(dfile, '[0-9]+(?=\\.nc)')
  
  # apply different polynomial transforms
  # apply per pixel mask
  # write to temporary file
  msk <- year * mask
  avg <- calc(msk, fun=mean, na.rm=T)
  writeRaster(avg, paste0(outtmp, '_', crop, '_', lname, '.grd'),
              format='raster')
  
  msk <- year * msk
  avg <- calc(msk, fun=mean, na.rm=T)
  writeRaster(avg, paste0(outtmp, '_', crop, '_', 'squared', '_', lname, '.grd'),
              format='raster')
  
  msk <- year * msk
  avg <- calc(msk, fun=mean, na.rm=T)
  writeRaster(avg, paste0(outtmp, '_', crop, '_', 'cubed', '_', lname, '.grd'),
              format='raster')
  
  # cleanup raster tmps
  unlink(raster_tmp, recursive=TRUE)
}

# # local test
# result <- do.call(parallel::mcMap, c(matrix_prep,
#                                      slurm_pars[3:4, , drop=FALSE],
#                                      mc.cores=2))

# apply matrix_prep over slurm_pars in parallel
slr_opt <- list(partition='sesync')
sjob_prep <- slurm_apply(matrix_prep, slurm_pars,
                         jobname='ddde_prep', nodes=8, cpus_per_node=6,
                         add_objects=c('outtmp'),
                         slurm_options=slr_opt)

# data for matrix_stack
slurm_pars <- expand.grid(crop=crops,
                          transform=c('', '_squared', '_cubed'),
                          stringsAsFactors=FALSE)

# function to combine annual tmp files into raster stacks for all years by crop and by polynomial transform
matrix_stack <- function(crop, transform) {
  
  # list grd and gri files for crop and transform
  dlist <- Sys.glob(paste0(outtmp, '_', crop, transform, '*'))
  
  # recover years from .grd files only
  ylist <- str_extract(dlist, '[0-9]+(?=\\.grd)')
  
  # get indices for .grd files ordered by year
  idx <- order(as.integer(ylist), na.last=TRUE)
  idx <- idx[1:sum(!is.na(ylist))]
  
  d <- stack(dlist[idx])
  names(d) <- ylist[idx]
  writeRaster(d, paste0(outfn, '_', crop, transform, '.grd'),
              format='raster')
  file.remove(dlist)
  
  if (length(dir(outtmp)) == 0) file.remove(outtmp)
}

# # serial test
# matrix_stack(crops[[1]], '')

# apply matrix_stack over slurm_pars in parallel
slr_opt <- list(partition='sesync',
                dependency=paste0('afterany:', sjob_prep$jobid))
sjob_stack <- slurm_apply(matrix_stack, slurm_pars,
                          jobname='ddde_stack', nodes=3, cpus_per_node=5,
                          add_objects=c('outfn', 'outtmp'),
                          slurm_options=slr_opt)

# will have to manually cleanup the _rslurm* folders
# cleanup_files(sjob_prep)
# cleanup_files(sjob_stack)
