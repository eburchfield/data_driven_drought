library(rgdal)
library(raster)
library(rslurm)
library(reshape2)

# This script extracts the mean of all unmasked pixels in the 3108 counties in the contiguous US.

###########################################################################################
# User inputs
##########################################################################################

# 2. Identify crop for which you'd like to construct a dataset: wheat, soy, maize, eco

crop <- "soy"  #wheat, soy, maize, eco, ag

# 1. First, if the user has a list of rasters to run through the extract function, 
#    generate a variable that is a list of the raster dataset, e.g.
#    data_list <- Sys.glob(paste('/nfs/datadrivendroughteffect-data/Data/NDVI/','*', 'wheat.tif',sep="")).
#    If the user only has one raster (i.e. one annual datacube), then read this into an object called "data_brick"
#    using the "brick" command, e.g. data_brick <- raster('filename.extension')

#data_brick <- lapply(data_list, brick)  #comment out this line if you are directly reading in a single raster brick

data_brick <- paste("/nfs/datadrivendroughteffect-data/Data/soil_moisture/modeled_soil_moisture/NLDAS_annual_soilmoisture_", 
                          crop, "_frac_1991-2015.nc", sep="")
data_brick <- lapply(data_brick, brick)

# 3. Specify filename for final RDS panel dataset, which will be in the Final_panels directory.  
#    format: DATASETNAME_TIMESTEP_CROP.rds

fn <- paste('/nfs/datadrivendroughteffect-data/Data/Final_panels/NLDAS_annual_soil_moisture_', crop, '_frac.rds', sep='')

# 4.  BE SURE TO GO LOOK AT STEP 3 BELOW TO MAKE SURE YOUR TIME INFORMATION IS PROPERLY TRANSMITTED TO THE FINAL DATAFRAME!!!



##########################################################################################
# 1.  Run RSLURM job on cluster
##########################################################################################

# Load shapefile
shp_data <- shapefile('/nfs/datadrivendroughteffect-data/Data/County_shp/cty_ndvi_proj.shp')

# Specify extraction function
extract_data <- function(i) {
  do.call(cbind, lapply(data_brick, function(rast) {
    extract(rast, shp_data[i,], fun=mean, na.rm=TRUE)
  }))
}

# Submit job to rslurm
sjob <- slurm_apply(extract_data, data.frame(i = seq_along(shp_data)),
                    nodes = 10, cpus_per_node = 8,
                    add_objects = c("data_brick", "shp_data"), 
                    slurm_options = list(partition = "sesync"))

# Check job status (Note: if you run subsequent lines before job is complete, this will cancel the job)
print_job_status(sjob)


############################################################################################
# 2.  Construct panel dataset
############################################################################################

# One the job is complete, extract data from the sjob object
res <- get_slurm_out(sjob, "table")
out_data <- as.data.frame(res)

# Extract and construct ancillary dataset from county shapefile

# Percent county covered in crop
cty_perc <- readRDS(Sys.glob(paste('/nfs/datadrivendroughteffect-data/Data/Landuse/cty_perc_', crop, '.rds',sep="")))

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

########################################################################################################
# 3. Extract relevant date information from column names - USER INPUT NEEDED
########################################################################################################

# 3.1 Extract relevant time information (YEAR and WEEK) from the band names

# Note: Depending on formatting of the variable naming convention of the bands in your raster brick, you'll have to play with this
#       to extract the YEAR or WEEK (if weekly) infomration from your dataset.  I've listed a few commented out lines of code that 
#       should help.

#name <- as.character(dft$CNAME[1])
#week <- as.numeric(sub('.*\\.', '', name))  #only relevant if weekly data
#year <- as.numeric(substr(name, 6, 9))  #indexing varies depending on dataset


# 3.2 Assign time variables to new columns in the final dataframe (dft$YEAR and dft$WEEK)

dft$YEAR <- as.numeric(substr(dft$CNAME, 2, 5))
#dft$WEEK <- as.numeric(sub('.*\\.', '', dft$CNAME))

########################################################################################################
# 4. Clean dataset and write out
########################################################################################################

drops <- c("CNAME")
dft <- dft[ , !(names(dft) %in% drops)]

saveRDS(dft, fn)
cleanup_files(sjob)
