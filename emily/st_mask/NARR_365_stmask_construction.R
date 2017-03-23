#ag/eco fraction

library(rgdal)
library(raster)
library(sp)

setwd("/nfs/datadrivendroughteffect-data/Data/Masks/")

#####################################################################################################################################
# LOAD DATA
#####################################################################################################################################

#load NARR data
data_prj <- brick('/nfs/datadrivendroughteffect-data/Data/NARR/air.2m.1981.nc')
data <- data_prj[[1]]
#projection is absolutely crazy, so I transform to WGS for all the analysis, then back project the stacks at the end
data <- projectRaster(data, crs = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs "))
n <- 365 #time step within year

#####################################################################################################################################
# TEMPORAL MASK
#####################################################################################################################################

# #seasonal stop/start information
# soy_start_fn <- '/nfs/datadrivendroughteffect-data/Data/Seasonal_stop_start/ALL_CROPS_ArcINFO_5min_filled/Soybeans.crop.calendar.fill/plant.start.asc'
# soy_stop_fn <- '/nfs/datadrivendroughteffect-data/Data/Seasonal_stop_start/ALL_CROPS_ArcINFO_5min_filled/Soybeans.crop.calendar.fill/harvest.end.asc'
# wheat_start_fn <- '/nfs/datadrivendroughteffect-data/Data/Seasonal_stop_start/ALL_CROPS_ArcINFO_5min_filled/Wheat.crop.calendar.fill/plant.start.asc'
# wheat_stop_fn <- '/nfs/datadrivendroughteffect-data/Data/Seasonal_stop_start/ALL_CROPS_ArcINFO_5min_filled/Wheat.crop.calendar.fill/harvest.end.asc'
# maize_start_fn <- '/nfs/datadrivendroughteffect-data/Data/Seasonal_stop_start/ALL_CROPS_ArcINFO_5min_filled/Maize.crop.calendar.fill/plant.start.asc'
# maize_stop_fn <- '/nfs/datadrivendroughteffect-data/Data/Seasonal_stop_start/ALL_CROPS_ArcINFO_5min_filled/Maize.crop.calendar.fill/harvest.end.asc'
# 
# #processing function
# image_prep <- function(filename){
#   ras <- raster(filename)
#   crs(ras) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs "
#   ras <- projectRaster(ras, crs = projection(data))
#   ras <- crop(ras, data)
#   ras <- resample(ras, data, method="ngb")
#   return(ras)
# }
# 
# #create stop/start rasters
# soy_start <- image_prep(soy_start_fn)
# soy_stop <- image_prep(soy_stop_fn)
# wheat_start <- image_prep(wheat_start_fn)
# wheat_stop <- image_prep(wheat_stop_fn)
# maize_start <- image_prep(maize_start_fn)
# maize_stop <- image_prep(maize_stop_fn)
# 
# #soy mask
# soy_start[is.na(soy_start)] <- 0
# soy_start_mask <- stack(mget(rep("soy_start",n)))
# soy_stop[is.na(soy_stop)] <- 0
# soy_stop_mask <- stack(mget(rep("soy_stop",n)))
# soy_stack <-  stack(mget(rep("soy_lulc",n)))  #check data, lulc projection
# soy_stack <- stack(data)
# for (i in 1:n) {
#   soy_stack[[i]] <- setValues(soy_stack[[i]], i)
# }
# soy_stack[soy_stack < soy_start_mask] <- NA
# soy_stack[soy_stack > soy_stop_mask] <- NA
# 
# #wheat mask
# wheat_start[is.na(wheat_start)] <- 0
# wheat_start_mask <- stack(mget(rep("wheat_start",n)))
# wheat_stop[is.na(wheat_stop)] <- 0
# wheat_stop_mask <- stack(mget(rep("wheat_stop",n)))
# wheat_stack <-  stack(data)
# wheat_stack <- stack(mget(rep("wheat_stack", n)))
# for (i in 1:n) {
#   wheat_stack[[i]] <- setValues(wheat_stack[[i]], i)
# }
# wheat_stack[wheat_stack < wheat_start_mask] <- NA
# wheat_stack[wheat_stack > wheat_stop_mask] <- NA
# 
# #maize mask
# maize_start[is.na(maize_start)] <- 0
# maize_start_mask <- stack(mget(rep("maize_start",n)))
# maize_stop[is.na(maize_stop)] <- 0
# maize_stop_mask <- stack(mget(rep("maize_stop",n)))
# maize_stack <-  stack(data)
# maize_stack <- stack(mget(rep("maize_stack", n)))
# for (i in 1:n) {
#   maize_stack[[i]] <- setValues(maize_stack[[i]], i)
# }
# maize_stack[maize_stack < maize_start_mask] <- NA
# maize_stack[maize_stack > maize_stop_mask] <- NA
# 
# #average agricultural start/stop dates
# 
# image_prep_time <- function(filename){
#   ras <- raster(filename)
#   crs(ras) <- "+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +a=6370997 +b=6370997 +units=m +no_defs "
#   ras <- projectRaster(ras, crs = projection(data))
#   ras <- crop(ras, data)
#   ras <- resample(ras, data, method="ngb")
#   return(ras)
# }
# 
# start <- image_prep_time('/nfs/datadrivendroughteffect-data/Data/Seasonal_stop_start/start.tif')
# start[is.na(start)] <- 0
# start_mask <- stack(mget(rep("start",n)))
# stop <- image_prep_time('/nfs/datadrivendroughteffect-data/Data/Seasonal_stop_start/stop.tif')
# stop[is.na(stop)] <- 0
# stop_mask <- stack(mget(rep("stop",n)))
# ag_stack <-  stack(data)
# ag_stack <- stack(mget(rep("ag_stack", n)))
# for (i in 1:n) {
#   ag_stack[[i]] <- setValues(ag_stack[[i]], i)
# }
# ag_stack[ag_stack < start_mask] <- NA
# ag_stack[ag_stack > stop_mask] <- NA
# 
# remove(start_mask, stop_mask, soy_start_mask, soy_stop_mask, wheat_start_mask, wheat_stop_mask, maize_start_mask, maize_stop_mask)
# 
# soy_stack <- brick("/nfs/datadrivendroughteffect-data/Data/Masks/time_masks/PRISM_365_soy.nc")
# wheat_stack <- brick("/nfs/datadrivendroughteffect-data/Data/Masks/time_masks/PRISM_365_wheat.nc")
# maize_stack <- brick("/nfs/datadrivendroughteffect-data/Data/Masks/time_masks/PRISM_365_maize.nc")
# ag_stack <- brick("/nfs/datadrivendroughteffect-data/Data/Masks/time_masks/PRISM_365_agriculture.nc")
# 
# #reproject, check projection, then resave.
# soy_stack_prj <- projectRaster(soy_stack, data_prj)
# wheat_stack_prj <- projectRaster(wheat_stack, data_prj)
# maize_stack_prj <- projectRaster(maize_stack, data_prj)
# ag_stack_prj <- projectRaster(ag_stack, data_prj)
# 
# writeRaster(soy_stack_prj, filename = "/nfs/datadrivendroughteffect-data/Data/Masks/time_masks/NARR_365_soy.nc", format="CDF", overwrite=T)
# writeRaster(wheat_stack_prj, filename = "/nfs/datadrivendroughteffect-data/Data/Masks/time_masks/NARR_365_wheat.nc", format="CDF", overwrite=T)
# writeRaster(maize_stack_prj, filename = "/nfs/datadrivendroughteffect-data/Data/Masks/time_masks/NARR_365_maize.nc", format="CDF", overwrite=T)
# writeRaster(ag_stack_prj, filename = "/nfs/datadrivendroughteffect-data/Data/Masks/time_masks/NARR_365_agriculture.nc", format="CDF",overwrite=T)

#####################################################################################################################################
# CATEGORICAL SPATIAL MASK
#####################################################################################################################################

#open time masks
wheat <- brick("/nfs/datadrivendroughteffect-data/Data/Masks/time_masks/NARR_365_wheat.nc")
soy <- brick("/nfs/datadrivendroughteffect-data/Data/Masks/time_masks/NARR_365_soy.nc")
maize <- brick("/nfs/datadrivendroughteffect-data/Data/Masks/time_masks/NARR_365_maize.nc")

#lulc categorical mask
lulc <- raster("/nfs/datadrivendroughteffect-data/Data/Masks/we_run/NARR_lulc_final.tif")
lulc_mask <- stack(mget(rep("lulc",n)))

#wheat listed as (24) winter wheat which grows from September to November, (22) durum wheat and (23) spring wheat
#since we focus on the spring/summer growing season, wheat == 22 and 23
wheat[lulc_mask > 23] <- NA
wheat[lulc_mask < 22] <- NA
writeRaster(wheat, filename = "/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/NARR_365_wheat.nc", format="CDF",overwrite=T)

#soy == 5
soy[lulc_mask != 5] <- NA
writeRaster(soy, filename = "/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/NARR_365_soy.nc", format="CDF",overwrite=T)

#maize == 1
maize[lulc_mask != 1] <- NA
writeRaster(maize, filename = "/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/NARR_365_maize.nc", format="CDF",overwrite=T)

#ag/eco flag
image_prep_time <- function(filename){
  ras <- raster(filename)
  #crs(ras) <- "+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +a=6370997 +b=6370997 +units=m +no_defs "
  ras <- projectRaster(ras, crs = projection(wheat))
  ras <- crop(ras, wheat)
  ras <- resample(ras, wheat, method="ngb")
  return(ras)
}
lulc_bin <- image_prep_time("/nfs/datadrivendroughteffect-data/Data/Landuse/lulc_bin.tif") 
lulc_bin_mask <- stack(mget(rep("lulc_bin",n)))
writeRaster(lulc_bin_mask, "/nfs/datadrivendroughteffect-data/Data/Masks/time_masks/NARR_365_ecological.nc", format="CDF", overwrite=T)

ag <- raster("/nfs/datadrivendroughteffect-data/Data/Masks/time_masks/NARR_365_agriculture.nc")
ag[lulc_bin_mask != 2] <- NA
writeRaster(ag, filename = "/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/NARR_365_ag.nc", format="CDF",overwrite=T)

eco <- lulc_bin_mask
eco[eco != 1] <- NA
writeRaster(eco, filename = "/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/NARR_365_eco.nc", format="CDF",overwrite=T)




#####################################################################################################################################
# FRACTION SPATIAL MASK
#####################################################################################################################################

#open time masks
wheat <- brick("/nfs/datadrivendroughteffect-data/Data/Masks/time_masks/NARR_365_wheat.nc")
soy <- brick("/nfs/datadrivendroughteffect-data/Data/Masks/time_masks/NARR_365_soy.nc")
maize <- brick("/nfs/datadrivendroughteffect-data/Data/Masks/time_masks/NARR_365_maize.nc")
ag <- brick("/nfs/datadrivendroughteffect-data/Data/Masks/time_masks/NARR_365_agriculture.nc")
eco <- brick("/nfs/datadrivendroughteffect-data/Data/Masks/time_masks/NARR_365_ecological.nc") #where == 1

#land use fraction rasters
wheat_lulc <- raster("/nfs/datadrivendroughteffect-data/Data/Masks/lulc_frac/wheat_narr.nc")
soy_lulc <- raster("/nfs/datadrivendroughteffect-data/Data/Masks/lulc_frac/soy_narr.nc")
maize_lulc <- raster("/nfs/datadrivendroughteffect-data/Data/Masks/lulc_frac/maize_narr.nc")
ag_lulc <- raster("/nfs/datadrivendroughteffect-data/Data/Masks/lulc_frac/ag_narr.nc")
eco_lulc <- raster("/nfs/datadrivendroughteffect-data/Data/Masks/lulc_frac/eco_narr.nc")

#land use fraction masks
wheat_lulc_mask <- stack(mget(rep("wheat_lulc",n)))
soy_lulc_mask <- stack(mget(rep("soy_lulc",n)))
maize_lulc_mask <- stack(mget(rep("maize_lulc",n)))
ag_lulc_mask <- stack(mget(rep("ag_lulc", n)))
eco_lulc_mask <- stack(mget(rep("eco_lulc", n)))

#wheat
wheat[wheat > 0] <- 0 #set non-NAs to zero
wheat <- wheat + wheat_lulc_mask #add wheat to land use fraction values
wheat[wheat == 0] <- NA #if land use fraction is zero set to NA
writeRaster(wheat, filename = "/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/NARR_365_wheat_frac.nc", format="CDF",overwrite=T)

#soy
soy[soy > 0] <- 0 #set non-NAs to zero
soy <- soy + soy_lulc_mask #add wheat to land use fraction values
soy[soy == 0] <- NA #if land use fraction is zero set to NA
writeRaster(soy, filename = "/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/NARR_365_soy_frac.nc", format="CDF",overwrite=T)

#maize
maize[maize > 0] <- 0 #set non-NAs to zero
maize <- maize + maize_lulc_mask #add wheat to land use fraction values
maize[maize == 0] <- NA #if land use fraction is zero set to NA
writeRaster(maize, filename = "/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/NARR_365_maize_frac.nc", format="CDF",overwrite=T)

#agriculture
ag[ag > 0] <- 0 #set non-NAs to zero
ag <- ag + ag_lulc_mask #add wheat to land use fraction values
ag[ag == 0] <- NA #if land use fraction is zero set to NA
writeRaster(ag, filename = "/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/NARR_365_ag_frac.nc", format="CDF",overwrite=T)

#ecological, where == 1
eco[eco > 0] <- 0 #set non-NAs to zero
eco <- eco + eco_lulc_mask #add wheat to land use fraction values
eco[eco == 0] <- NA #if land use fraction is zero set to NA
writeRaster(eco, filename = "/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/NARR_365_eco_frac.nc", format="CDF",overwrite=T)

