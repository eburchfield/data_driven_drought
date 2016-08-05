library(rgdal)
library(raster)
library(SDMTools)
library(sp)
#Z or nfs/datadrivendroughteffect-data

#reference NDVI image
ndvi_list <- Sys.glob(paste('Z:/Data/NDVI/',"*",'ndvi_final.tif',sep=""))  #n = 1373
ndvi <- raster(ndvi_list[1])
ndvi_wgs <- projectRaster(ndvi, crs=projection(soy_start))

#county shapefile
shp_dr <- 'Z:/Data/County_shp/cb_2015_us_county_500k.shp'
shp_data <- readOGR(dsn=shp_dr, layer = "cb_2015_us_county_500k", stringsAsFactors=F)
shp_data <- spTransform(shp_data, projection(ndvi))

#processing function
image_prep <- function(filename){
  ras <- raster(filename)
  crs(ras) <- "+init=epsg:4326" #define projection
  ras_usa <- crop(ras, ndvi_wgs) #clip to extent of NDVI dataset
  ras <- projectRaster(ras_usa, crs = projection(ndvi))
  ras <- crop(ras, ndvi) #clip to extent of NDVI dataset
  return(ras)
}

#filenames
soy_start_fn <- 'Z:/Data/Seasonal_stop_start/ALL_CROPS_ArcINFO_5min_filled/Soybeans.crop.calendar.fill/plant.start.asc'
soy_stop_fn <- 'Z:/Data/Seasonal_stop_start/ALL_CROPS_ArcINFO_5min_filled/Soybeans.crop.calendar.fill/harvest.end.asc'
wheat_start_fn <- 'Z:/Data/Seasonal_stop_start/ALL_CROPS_ArcINFO_5min_filled/Wheat.crop.calendar.fill/plant.start.asc'
wheat_stop_fn <- 'Z:/Data/Seasonal_stop_start/ALL_CROPS_ArcINFO_5min_filled/Wheat.crop.calendar.fill/harvest.end.asc'
maize_start_fn <- 'Z:/Data/Seasonal_stop_start/ALL_CROPS_ArcINFO_5min_filled/Maize.crop.calendar.fill/plant.start.asc'
maize_stop_fn <- 'Z:/Data/Seasonal_stop_start/ALL_CROPS_ArcINFO_5min_filled/Maize.crop.calendar.fill/harvest.end.asc'
sorghum_start_fn <- 'Z:/Data/Seasonal_stop_start/ALL_CROPS_ArcINFO_5min_filled/Sorghum.crop.calendar.fill/plant.start.asc'
sorghum_stop_fn <- 'Z:/Data/Seasonal_stop_start/ALL_CROPS_ArcINFO_5min_filled/Sorghum.crop.calendar.fill/harvest.end.asc'
cotton_start_fn <- 'Z:/Data/Seasonal_stop_start/ALL_CROPS_ArcINFO_5min_filled/Cotton.crop.calendar.fill/plant.start.asc'
cotton_stop_fn <- 'Z:/Data/Seasonal_stop_start/ALL_CROPS_ArcINFO_5min_filled/Cotton.crop.calendar.fill/harvest.end.asc'
rice_start_fn <- 'Z:/Data/Seasonal_stop_start/ALL_CROPS_ArcINFO_5min_filled/Rice.crop.calendar.fill/plant.start.asc'
rice_stop_fn <- 'Z:/Data/Seasonal_stop_start/ALL_CROPS_ArcINFO_5min_filled/Rice.crop.calendar.fill/harvest.end.asc'

soy_start <- image_prep(soy_start_fn)
soy_stop <- image_prep(soy_stop_fn)
wheat_start <- image_prep(wheat_start_fn)
wheat_stop <- image_prep(wheat_stop_fn)
maize_start <- image_prep(maize_start_fn)
maize_stop <- image_prep(maize_stop_fn)
sorghum_start <- image_prep(sorghum_start_fn)
sorghum_stop <- image_prep(sorghum_stop_fn)
cotton_start <- image_prep(cotton_start_fn)
cotton_stop <- image_prep(cotton_stop_fn)
rice_start <- image_prep(rice_start_fn)
rice_stop <- image_prep(rice_stop_fn)

#average stop/start date for major crops in region
start <- stack(soy_start, wheat_start, maize_start, sorghum_start, cotton_start, rice_start)
stop <- stack(soy_stop, wheat_stop, maize_stop, sorghum_stop, cotton_stop, rice_stop)

start_mean <- mean(start) #mean along third dimension
stop_mean <- mean(stop)

#extract values to pixels
#rs_start <- resample(start_mean, ndvi, method="bilinear")
#rs_stop <- resample(stop_mean, ndvi, method="bilinear")

rs_start <- raster("start.tif")
rs_stop <- raster("stop.tif")

#write out final stop/start ratser
#writeRaster(rs_start, filename = "start.tif")
#writeRaster(rs_stop, filename="stop.tif")


crop_flag <- function(filename){
  ras <- raster(filename)
  doy <- as.numeric(substr(filename, 26, 28)) #take final date
  
  xy <- matrix(22,2889,4587)
  rast <- raster(xy)
  extent(rast) <- extent(rs_start)
  projection(rast) <- projection(rs_start)
  
  rast[rast == 22] <- doy
  rast[rast < rs_start] <- 0
  rast[rast > rs_stop] <- 0
  rast[rast > 0] <- 1
  
  return(rast)
}

for (i in seq(1,length(ndvi_list))) {
  filename <- ndvi_list[i]
  out_name <- paste(substr(filename, 0, 8),"Seasonal_stop_start/stop_start_flag", substr(filename, 13, 29),"season_flag.tif",sep="")
  out_raster <- crop_flag(filename)
  writeRaster(out_raster, out_name)
  print(paste0("Currently saving: ", out_name))
}



