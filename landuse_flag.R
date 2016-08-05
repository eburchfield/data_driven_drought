library(rgdal)
library(raster)
library(sp)

#Lambert Azimuthal Equal Area

#load data
data_dr <- '/nfs/datadrivendroughteffect-data/Data/NDVI/'
data_ex <- 'ndvi.tif'
data_list <- Sys.glob(paste(data_dr,"*",data_ex,sep=""))  #n = 1373

#add land use flag
nlcd_list <- Sys.glob(paste("/nfs/datadrivendroughteffect-data/Data/Landuse/NLCD/","*",".img",sep=""))
lu01 <- raster(nlcd_list[2])
lu06 <- raster(nlcd_list[3])
lu11 <- raster(nlcd_list[4])

#reference ndvi
final_list <- Sys.glob(paste(data_dr,"*","_final.tif",sep=""))  
ndvi <- raster(final_list[1])

#subset test
shp_dr <- '/nfs/datadrivendroughteffect-data/Data/County_shp/cb_2015_us_county_500k.shp'
shp_data <- readOGR(dsn=shp_dr, layer = "cb_2015_us_county_500k", stringsAsFactors=F)
shp_data <- spTransform(shp_data, projection(ndvi))


ag01 <- aggregate(lu01, fact=30, fun=modal, na.rm=T) #from 30 meter to 30*30 meter
ag06 <- aggregate(lu06, fact=30, fun=modal, na.rm=T) #from 30 meter to 30*30 meter
ag11 <- aggregate(lu11, fact=30, fun=modal, na.rm=T) #from 30 meter to 30*30 meter

ag01_p <- projectRaster(ag01, ndvi, method="ngb")
ag06_p <- projectRaster(ag06, ndvi, method="ngb")
ag11_p <- projectRaster(ag11, ndvi, method="ngb")

rs01 <- resample(ag01_p, ndvi, method="ngb")
rs06 <- resample(ag06_p, ndvi, method="ngb")
rs11 <- resample(ag11_p, ndvi, method="ngb")

writeRaster(rs01, filename = "ag2001.tif", overwrite=T)
writeRaster(rs06, filename = "ag2006.tif", overwrite=T)
writeRaster(rs11, filename = "ag2011.tif", overwrite=T)

lulc_stack <- stack(rs01, rs06, rs11)

Mode <- function(x) {
  ux <- unique(x)
  ux=ux[!is.na(ux)]
  ux[which.max(tabulate(match(x, ux)))]
}

lulc <- calc(lulc_stack, fun=Mode)
writeRaster(lulc, filename="lulc.tif")

#ag/eco flag

#agriculture (2)
lulc[lulc == 81] <- 2 #pasture/hay
lulc[lulc == 82] <- 2 #crops

#eco (1)
lulc[lulc == 41] <- 1 #deciduous forest
lulc[lulc == 42] <- 1 #evergreen forest
lulc[lulc == 43] <- 1 #mixed forest
lulc[lulc == 52] <- 1 #shrub
lulc[lulc == 71] <- 1 #grassland
lulc[lulc == 90] <- 1 #wetlands
lulc[lulc == 95] <- 1 #wetlands

#other (0)
lulc[lulc > 2] <- 0

writeRaster(lulc, filename="lulc_bin.tif")

