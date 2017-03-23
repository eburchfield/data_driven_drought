library(rgdal)
library(raster)
library(sp)

setwd("/nfs/datadrivendroughteffect-data/Data/Masks/")
load("/nfs/datadrivendroughteffect-data/Data/Masks/stmask_construction.RData")

# #load data
# data <- brick('/nfs/datadrivendroughteffect-data/Data/PRISM/PRISM_daily_ppt_1981.nc')
# n <- 365 #time step within year
# 
# #####################################################################################################################################
# # TEMPORAL MASK
# #####################################################################################################################################
# 
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
#   crs(ras) <- "+init=epsg:4326" 
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
# soy_stack <-  stack(data)
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
# for (i in 1:n) {
#   ag_stack[[i]] <- setValues(ag_stack[[i]], i)
# }
# ag_stack[ag_stack < start_mask] <- NA
# ag_stack[ag_stack > stop_mask] <- NA

save.image("/nfs/datadrivendroughteffect-data/Data/Masks/stmask_construction.RData")

writeRaster(soy_stack, filename = "/nfs/datadrivendroughteffect-data/Data/Masks/time_masks/PRISM_365_soy.nc", format="CDF", overwrite=T)
writeRaster(wheat_stack, filename = "/nfs/datadrivendroughteffect-data/Data/Masks/time_masks/PRISM_365_wheat.nc", format="CDF", overwrite=T)
writeRaster(maize_stack, filename = "/nfs/datadrivendroughteffect-data/Data/Masks/PRISM_365_maize.nc", format="CDF", overwrite=T)
writeRaster(ag_stack, filename = "/nfs/datadrivendroughteffect-data/Data/Masks/PRISM_365_agriculture.nc", format="CDF",overwrite=T)

#clean up files tomorrow

#####################################################################################################################################
# SPATIAL MASK
#####################################################################################################################################

#landuse data
cs_list <- Sys.glob(paste("/nfs/datadrivendroughteffect-data/Data/Landuse/CropScape/","*","_30m_cdls.img",sep=""))
lulc_stk <- stack(raster(cs_list[1]), raster(cs_list[2]), raster(cs_list[3]), raster(cs_list[4]),
                  raster(cs_list[5]), raster(cs_list[6]), raster(cs_list[7]))
#take mode through time
Mode <- function(x) {as.numeric(names(which.max(table(x))))}
lulc <- calc(lulc_stk, fun=Mode)
save.image("/nfs/datadrivendroughteffect-data/Data/Masks/stmask_construction.RData")

image_prep_lulc <- function(){
  ras <- projectRaster(lulc, crs = projection(data))
  ras <- crop(ras, data) 
  ras <- resample(ras, data, method="ngb")
  return(ras)
}
lulc_prj <- image_prep_lulc()
writeRaster(lulc, filename = "/nfs/datadrivendroughteffect-data/Data/Masks/PRISM_365_lulc_mode.tif", overwrite=T)
lulc_mask <- stack(mget(rep("lulc",n)))

#crop subset
#wheat listed as (24) winter wheat which grows from September to November, (22) durum wheat and (23) spring wheat
#since we focus on the spring/summer growing season, wheat == 22 and 23
wheat <- wheat_stack
wheat[lulc_mask > 23] <- NA
wheat[lulc_mask < 22] <- NA

#soy == 5
soy <- soy_stack
soy[lulc_mask != 5] <- NA

#maize == 1
maize <- maize_stack
maize[lulc_mask != 1] <- NA

#ag/eco flag
lulc_bin <- image_prep_time("/nfs/datadrivendroughteffect-data/Data/Landuse/lulc_bin.tif") #eco == 1, agro == 2
lulc_bin_mask <- stack(mget(rep("lulc_bin",n)))

ag <- ag_stack
ag[lulc_bin_mask != 2] <- NA

eco <- lulc_bin_mask
eco[eco != 1] <- NA

save.image("/nfs/datadrivendroughteffect-data/Data/Masks/stmask_construction.RData")


#writeRaster(ag, "/nfs/datadrivendroughteffect-data/Data/Masks/PRISM_365_agriculture.nc", format="CDF", overwrite=T)
#writeRaster(eco, "/nfs/datadrivendroughteffect-data/Data/Masks/PRISM_365_ecological.nc", format="CDF", overwrite=T)






