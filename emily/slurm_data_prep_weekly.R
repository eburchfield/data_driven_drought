#devtools::install_github("sesync-ci/rslurm", ref="wait")
library(raster)
library(rslurm)
library(stringr)
library(ncdf4)

crops <- c("ag", "eco", "maize", "wheat", "soy")
outtmp <- '/nfs/scratch/ddde/'
dir.create(outtmp, showWarnings=FALSE)

# UPDATE FOR EACH DATASET
res <- '365'                # "weekly", "365", 
dname <- 'NLDAS'            # "NARR", "NLDAS", "PRISM"
outfn <- '/nfs/datadrivendroughteffect-data/Data/Masked_weekly_data/NLDAS_annual_sm'
dlist <- Sys.glob(paste0('/nfs/datadrivendroughteffect-data/Data/soil_moisture/annual_soil_moisture_bricks/','*','.nc'))
#Sys.glob(paste0('/nfs/datadrivendroughteffect-data/Data/PRISM/PRISM_Z_tavg', '_', '*', '.nc'))
weeks <- seq(1, 365, by=7)


slurm_pars <- expand.grid(dname=dname, dfile=dlist,
                          res=res, crop=crops, week=weeks, stringsAsFactors=FALSE)

matrix_prep <- function(dname, dfile, res, crop, week) {
  
  # set thread-specific, local tmp dir for raster calculations
  raster_tmp <- paste0('/tmp/ddde_raster_', Sys.getpid())
  dir.create(raster_tmp)
  rasterOptions(tmpdir=raster_tmp)
  
  # aquire annual brick
  year <- brick(dfile)
  
  # extract name of future layer
  lname <- str_extract(dfile, '[0-9]+(?=\\.nc)')
  
  # n days in year
  ndays <- dim(year)[3]

  # aquire mask
  mask <- brick(paste0('/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/',
                       dname, '_', res, '_', crop, '_frac.nc'))
  
  # account for leap years
  mask <- mask[[1:ndays]]
  
  # apply transforms per week
      msk <- year * mask
      start <- week
      stop <- start+6
      msk <- msk[[start:stop]]
      avg <- calc(msk, fun=mean, na.rm=T)
      writeRaster(avg, paste0(outtmp, '_', crop, '_', lname, '_', 'w', week, '.grd'),
              format='raster')
  
      msk <- year[[start:stop]] * msk
      avg <- calc(msk, fun=mean, na.rm=T)
      writeRaster(avg, paste0(outtmp, '_', crop, '_', 'squared', '_', lname, '_', 'w', week, '.grd'),
                  format='raster')
      
      msk <- year[[start:stop]] * msk
      avg <- calc(msk, fun=mean, na.rm=T)
      writeRaster(avg, paste0(outtmp, '_', crop, '_', 'cubed', '_', lname, '_', 'w', week, '.grd'),
                  format='raster')
      
      # cleanup raster tmps
      unlink(raster_tmp, recursive=TRUE)
  
}

# # local test
#result <- do.call(parallel::mcMap, c(matrix_prep,
#                                      slurm_pars[13:14, , drop=FALSE],
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
  dlist <- Sys.glob(paste0(outtmp, '_', crop, transform, '_[0-9]', '*.grd'))
  match <- str_match(dlist, '.*_([0-9]+)_w([0-9]+)\\.grd')
  
  year <- seq(as.numeric(min(match[,2])), as.numeric(max(match[,2])), by=1)
  for (i in 1:length(unique(match[,2]))) {

    # select data for each year
    yr <- year[i]
    df <- match[match[,2] == yr,]
    
    # get indices for .grd files ordered by year
    idx <- order(as.integer(df[,3]))
    wlist <- df[,3]
    
    d <- stack(dlist[idx])
    names(d) <- wlist[idx]
    writeRaster(d, paste0(outfn, '_', crop, transform, '_', yr, '.grd'), overwrite=T,
                format='raster')
    #file.remove(dlist)
    
    if (length(dir(outtmp)) == 0) file.remove(outtmp)
  }
  
  ylist <- Sys.glob(paste0(outfn, '_', crop, transform,'*.grd')) #sorted
  ylist2 <- Sys.glob(paste0(outfn, '_', crop, transform,'*.gri'))
  final <- stack(ylist)
  names(final) <- match[,2]
  writeRaster(final, paste0(outfn,'_', crop, transform,'.grd' ), overwrite=T, format='raster')

  for (fn in 1:length(ylist)) {
    file.remove(ylist[fn])
    file.remove(ylist2[fn])
  }
}
  
 
# # serial test
# matrix_stack(crops[[1]], '')

# apply matrix_stack over slurm_pars in parallel
slr_opt <- list(partition='sesynctest',
                dependency=paste0('afterany:', sjob_prep$jobid))
sjob_stack <- slurm_apply(matrix_stack, slurm_pars,
                          jobname='ddde_stack', nodes=3, cpus_per_node=5,
                          add_objects=c('outfn', 'outtmp'),
                          slurm_options=slr_opt)

all_files <- Sys.glob('/nfs/datadrivendroughteffect-data/Data/Masked_weekly_data/*')

# NOT DELETING FILES???????

# will have to manually cleanup the _rslurm* folders
# cleanup_files(sjob_prep)
# cleanup_files(sjob_stack)