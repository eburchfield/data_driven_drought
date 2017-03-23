library(rgdal)
library(raster)
library(rslurm)
library(reshape2)

#change YEAR/WEEK 

crop <- as.character("eco")  #wheat, soy, maize, eco

#objects
data_list <- Sys.glob(paste('/nfs/datadrivendroughteffect-data/Data/NDVI/','*', crop, '.tif',sep=""))
shp_data <- shapefile('/nfs/datadrivendroughteffect-data/Data/County_shp/cty_ndvi_proj.shp')
data_brick <- lapply(data_list, brick)

extract_data <- function(i) {
  do.call(cbind, lapply(data_brick, function(rast) {
    extract(rast, shp_data[i,], fun=mean, na.rm=TRUE)
  }))
}

sjob <- slurm_apply(extract_data, data.frame(i = seq_along(shp_data)),
                    nodes = 10, cpus_per_node = 8,
                    add_objects = c("data_brick", "shp_data"), 
                    slurm_options = list(partition = "sesync"))

print_job_status(sjob)
res <- get_slurm_out(sjob, "table")
out_data <- as.data.frame(res)

#ANCILLARY DATA
#percent county covered in crop
cty_perc <- readRDS(Sys.glob(paste('/nfs/datadrivendroughteffect-data/Data/Landuse/cty_perc_', crop, '.rds',sep="")))
#crop weights sum
cty_frac_sum <- readRDS(Sys.glob(paste('/nfs/datadrivendroughteffect-data/Data/Ancillary panel/cty_fracsum_', crop, '.rds',sep="")))
#county area
cty_area <- as.data.frame(shp_data$SQKM)
#county and state ID
cty_id <- as.data.frame(shp_data$COUNTYFP)
st_id <- as.data.frame(shp_data$STATEFP)

ancil_data <- cbind(st_id, cty_id, cty_perc, cty_frac_sum, cty_area)
colnames(ancil_data) <- c("STATEFP", "COUNTYFP", "PCT_CROP", "FRAC_SUM", "AREA_SQKM")


#CONSTRUCT FINAL DATASET
df <- cbind(ancil_data, out_data)
#http://data.library.virginia.edu/reshaping-data-from-wide-to-long/
dft <- melt(df, id.vars=c("STATEFP", "COUNTYFP", "PCT_CROP", "FRAC_SUM", "AREA_SQKM"),
            variable.name="CNAME", value.name="MEAN")
dft$CNAME <- as.character(dft$CNAME)

#name <- as.character(dft$CNAME[1])
#week <- as.numeric(sub('.*\\.', '', name))
#year <- as.numeric(substr(name, 6, 9))

dft$YEAR <- as.numeric(substr(dft$CNAME, 6, 9))
dft$WEEK <- as.numeric(sub('.*\\.', '', dft$CNAME))

drops <- c("CNAME")
dft <- dft[ , !(names(dft) %in% drops)]

#counties_wheat <- dft[apply(as.matrix(dft), 1, function(x) any(!is.na(x))),]


saveRDS(dft, '/nfs/datadrivendroughteffect-data/Data/Final_panels/NDVI_weekly_maize.rds')
cleanup_files(sjob)
