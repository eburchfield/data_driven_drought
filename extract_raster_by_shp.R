library(rgdal)
library(raster)
library(gdalUtils)
library(stringr)
library(rgeos)
library(dplyr)

#space-time resolution
#obs_per_year = 52; 
#missing data flag

#dataset to extract
data_dr <- '/nfs/datadrivendroughteffect-data/Data/NDVI/'
data_ex <- 'ndvi.tif'

#shapefile to extract to
shp_dr <- '/nfs/datadrivendroughteffect-data/data_driven_drought/cb_2015_us_county_500k.shp'
counties <- readOGR(dsn=shp_dr, layer = "cb_2015_us_county_500k", stringsAsFactors=F)

#raster
data_list <- Sys.glob(paste(data_dr,"*",data_ex,sep=""))
ndvi <- raster(data_list[100])
counties <- spTransform(counties, projection(ndvi))
#plot(ndvi)
#plot(counties, add=T)

#extract raster data by polgyon
#cropped subset
cty_md <- counties[counties$STATEFP == "24",]
state_md <- gUnaryUnion(cty_md)
ndvic <- crop(ndvi, extent(state_md))
cty_data <- extract(ndvic, cty_md, na.rm = TRUE, sp = TRUE) 
d <- data.frame(ID = cty_md$ID, cty_data)


#transform dataset to integer
#The NDVI computed value, which ranges from -1.0 to 1.0, is scaled to the range of 0 to 200, 
#where computed -1.0 equals 0, computed 0 equals 100, and computed 1.0 equals 200. 
i=1
out_fn = paste(str_sub(data_list[i], 1,-5),"f.tif",sep="")
gdal_translate(src_dataset = data_list[i], dst_dataset = paste(data_dr,"test2.tif",sep=""), scale = c(0, 200, -1.0, 1.0))
ndvir <- raster(paste(data_dr,"test2.tif",sep=""))
plot(ndvir)
ndvirp <- projectRaster(ndvir, crs=prj)  #takes a long time, 10 sec



#remove_list <- Sys.glob(paste(data_dr,"*ndvi.tfw",sep=""))  #all files with "date"

#mask
maxndvi <- cellStats(ndvip, "max")
minndvi <- cellStats(ndvip, "min")
ndvim <- mask(ndvip, ndvip< 0, maskvalue=T)



