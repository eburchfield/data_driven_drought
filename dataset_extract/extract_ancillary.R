library(raster)
library(rgeos)
library(rslurm)

#wheat mean(x %in% c(22, 23)
#soy 5
#maize 1


##################################################################################################################
# Percent crop by county
##################################################################################################################

lulc <- raster("/nfs/datadrivendroughteffect-data/Data/Masks/lulc_mode.grd")
shp_data <- shapefile('/nfs/datadrivendroughteffect-data/Data/County_shp/cty_ndvi_proj.shp')
shp_data <- spTransform(as(shp_data, "SpatialPolygons"), projection(lulc))

# Define helper functions
prop <- function(x, na.rm) {
  mean(x == 1, na.rm = na.rm)
}

extract_crop <- function(i) {
  extract(lulc, shp_data[i], fun = prop, na.rm = TRUE)
}

# Run extraction on cluster (projected run time: ~90 min for all data_prism)
sjob <- slurm_apply(extract_crop, data.frame(i = seq_along(shp_data)),
                    nodes = 12, cpus_per_node = 8, 
                    add_objects = c("lulc", "shp_data", "prop"),
                    slurm_options = list(partition = "sesync"))

#print_job_status(sjob)  

res <- get_slurm_out(sjob, outtype = "table")
out_data <- as.data.frame(res)
saveRDS(out_data, '/nfs/datadrivendroughteffect-data/Data/Landuse/cty_perc_maize.rds')

cleanup_files(sjob)


#percent eco
eco_lulc <- raster('/nfs/datadrivendroughteffect-data/Data/Landuse/eco_mask.tif')
eco_lulc[is.na(eco_lulc)] <- 0

# Define helper functions
prop <- function(x, na.rm) {
  mean(x == 2, na.rm = na.rm)
}

extract_crop <- function(i) {
  extract(eco_lulc, shp_data[i], fun = prop, na.rm = TRUE)
}

# Run extraction on cluster (projected run time: ~90 min for all data_prism)
sjob <- slurm_apply(extract_crop, data.frame(i = seq_along(shp_data)),
                    nodes = 12, cpus_per_node = 8, 
                    add_objects = c("eco_lulc", "shp_data", "prop"),
                    slurm_options = list(partition = "sesync"))

#print_job_status(sjob)  


res <- get_slurm_out(sjob, outtype = "table")
out_data <- as.data.frame(res)
saveRDS(out_data, '/nfs/datadrivendroughteffect-data/Data/Landuse/cty_perc_eco.rds') #eco

cleanup_files(sjob)


##################################################################################################################
# Sum fractional weights by county
##################################################################################################################

#fractional weights

wheat_lulc <- raster("/nfs/datadrivendroughteffect-data/Data/Masks/wheat_raster.grd")
soy_lulc <- raster("/nfs/datadrivendroughteffect-data/Data/Masks/soy_raster.grd")
maize_lulc <- raster("/nfs/datadrivendroughteffect-data/Data/Masks/maize_raster.grd")
#NOTE: do not need for eco since the resolution was the same

lulc <- eco_lulc  #change crop here
shp_data <- shapefile('/nfs/datadrivendroughteffect-data/Data/County_shp/cty_ndvi_proj.shp')
shp_data <- spTransform(as(shp_data, "SpatialPolygons"), projection(lulc))

sum <- function(x, na.rm) {
  sum(x, na.rm = na.rm)
}

sum_crop <- function(i) {
  extract(lulc, shp_data[i], fun = sum, na.rm = TRUE)
}

# Run extraction on cluster (projected run time: ~90 min for all data_prism)
sjob <- slurm_apply(sum_crop, data.frame(i = seq_along(shp_data)),
                    nodes = 12, cpus_per_node = 8, 
                    add_objects = c("lulc", "shp_data", "sum"),
                    slurm_options = list(partition = "sesync"))

#print_job_status(sjob)  

res <- get_slurm_out(sjob, outtype = "table")
out_data <- as.data.frame(res)
saveRDS(out_data, '/nfs/datadrivendroughteffect-data/Data/Ancillary panel/cty_fracsum_maize.rds')

cleanup_files(sjob)


