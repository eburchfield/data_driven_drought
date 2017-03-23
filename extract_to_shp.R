#devtools::install_github("SESYNC-CI/rslurm", ref="wait")

library(rgdal)
library(raster)
library(rslurm)
library(reshape2)

# Zprecip, Ztavg, Zdeficit, tmean, ppt, deficit
# ag zeros
# tmean
# OK: Zdeficit, Ztavg, ppt, Zprecip, deficit


setwd("/nfs/scratch/ddde")

# input masked data file list
data_list <- Sys.glob(paste('/nfs/datadrivendroughteffect-data/Data/Masked_data/PRISM_annual_Ztavg','*', '.grd', sep=''))
crop_list <- rep(rep(c("ag", "eco", "maize", "soy", "wheat"), each=3), 6)
shp_data <- shapefile('/nfs/datadrivendroughteffect-data/Data/County_shp/cty_ndvi_proj.shp')
dir <- '/nfs/datadrivendroughteffect-data/Data/Extracted_panels/'

# extract function
extract_data <- function(i) {
  extract(rast, shp_data[i,], fun=sum, na.rm=TRUE)
}

#construct panel function
construct_panel <- function(sjob) {

  # Extract and construct ancillary dataset from county shapefile
  res <- get_slurm_out(sjob, "table")
  out_data <- as.data.frame(res)
  
  # Percent county covered in crop
  cty_perc <- readRDS(Sys.glob(paste('/nfs/datadrivendroughteffect-data/Data/Landuse/cty_perc_', crop, '.rds', sep="")))
  
  # Crop weights sum
  if (crop == "eco") {
    cty_frac_sum <- as.data.frame(rep(NA,3108))
  } else if (crop == "ag") {
    cty_frac_sum <- as.data.frame(rep(NA,3108))
  } else {
    cty_frac_sum <- readRDS(Sys.glob(paste('/nfs/datadrivendroughteffect-data/Data/Ancillary panel/cty_fracsum_', crop, '.rds',sep="")))
  }
  
  # County area
  cty_area <- as.data.frame(shp_data$SQKM)
  
  # County and state ID
  cty_id <- as.data.frame(shp_data$COUNTYFP)
  st_id <- as.data.frame(shp_data$STATEFP)
  
  # Concatenate ancillary dataset and name columns
  ancil_data <- cbind(st_id, cty_id, cty_perc, cty_frac_sum, cty_area)
  colnames(ancil_data) <- c("STATEFP", "COUNTYFP", "PCT_CROP", "FRAC_SUM", "AREA_SQKM")
  
  # Merge RSLURM output and ancillary data
  df <- cbind(ancil_data, out_data)
  
  # Reshape final dataset 
  dft <- melt(df, id.vars=c("STATEFP", "COUNTYFP", "PCT_CROP", "FRAC_SUM", "AREA_SQKM"),
              variable.name="CNAME", value.name="MEAN")
  dft$CNAME <- as.character(dft$CNAME)
  dft$YEAR <- as.numeric(substr(dft$CNAME, 2, 5))
  
  drops <- c("CNAME")
  dft <- dft[ , !(names(dft) %in% drops)]
  
  # Crop weights sum
  if (crop == "eco") {
    dft$MEAN <- dft$MEAN
  } else if (crop == "ag") {
    dft$MEAN <- dft$MEAN
  } else {
    dft$MEAN <- dft$MEAN/dft$FRAC_SUM
  }
  
  saveRDS(dft, fn)
}

# loop through bricks  
for (n in 1:length(data_list)) {

  rast <- brick(data_list[n])
  crop <- crop_list[n]
  fn <- sub(".*_data/", "", data_list[n])
  fn <- paste(dir, sub('\\.grd$', '', fn), '.RDS', sep='')
  
  sjob1 <- slurm_apply(extract_data, data.frame(i = seq_along(shp_data)),
                       nodes = 10, cpus_per_node = 8,
                       add_objects = c("rast", "shp_data"), 
                       slurm_options = list(partition = "sesync", time='0-6:0:0')) 

  sopts <- list(
    partition = "sesyncshared",
    dependency = paste0("afterany:", sjob1$jobid))

  construct_panel(sjob1)
  #sjob2 <- slurm_call(construct_panel, list(sjob=sjob1), 
   #                   add_objects = c('shp_data', 'crop', 'fn'),  
    #                  slurm_options = sopts)
  
}


# One the job is complete, extract data from the sjob object
#res <- get_slurm_out(sjob2, "raw")
#out_data <- as.data.frame(res)
#saveRDS(out_data, fn)
#cleanup_files(sjob1)
#cleanup_files(sjob2)
