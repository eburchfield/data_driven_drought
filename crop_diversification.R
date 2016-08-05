library(rgdal)
library(raster)

#reference NDVI image
ndvi_list <- Sys.glob(paste('/nfs/datadrivendroughteffect-data/Data/NDVI/',"*",'ndvi_final.tif',sep=""))  #n = 1373
ndvi <- raster(ndvi_list[1])

#data prep
shp_dr <- '/nfs/datadrivendroughteffect-data/Data/County_shp/cb_2015_us_county_500k.shp'
shp_data <- readOGR(dsn=shp_dr, layer = "cb_2015_us_county_500k", stringsAsFactors=F)
shp_data <- spTransform(shp_data, projection(ndvi))

#land use raster
lu01 <- raster("ag2001.tif")
lu06 <- raster("ag2006.tif")
lu11 <- raster("ag2011.tif")

#extract landuse by county
extract_lu01 <- extract(lu01, shp_data, na.rm=T) 
extract_lu06 <- extract(lu06, shp_data, na.rm=T) 
extract_lu11 <- extract(lu11, shp_data, na.rm=T)

names(extract_lu01) <- shp_data$ID
names(extract_lu06) <- shp_data$ID
names(extract_lu11) <- shp_data$ID

#cd loop for each year

#2001
final_cd_01 <- list()
lulc_idx <- unique(lu01)

#loop through counties
for (name in names(extract_lu01)) {
  data <- extract_lu01[[name]]
  total_area <- length(data)
  count <- 0
  
  for (i in 1:length(lulc_idx)) {
    lc_count <- length(data[data == lulc_idx[i]])
    out <- ifelse(lc_count == 0, 0, -(lc_count/total_area)*log(lc_count/total_area))
    count <- count + out
  }
    
  final_cd_01[[name]] <- count  
}

final_2001 <- do.call(rbind, final_cd_01)
write.table(final_2001, file = "cd2001.txt", sep = " ", row.names=T, col.names=F)

#2006
final_cd_06 <- list()
lulc_idx <- unique(lu06)

#loop through counties
for (name in names(extract_lu06)) {
  data <- extract_lu06[[name]]
  total_area <- length(data)
  count <- 0
  
  for (i in 1:length(lulc_idx)) {
    lc_count <- length(data[data == lulc_idx[i]])
    out <- ifelse(lc_count == 0, 0, -(lc_count/total_area)*log(lc_count/total_area))
    count <- count + out
  }
  
  final_cd_06[[name]] <- count  
}

final_2006 <- do.call(rbind, final_cd_06)
write.table(final_2006, file = "cd2006.txt", sep = " ", row.names=T, col.names=F)


#2011
final_cd_11 <- list()
lulc_idx <- unique(lu11)

#loop through counties
for (name in names(extract_lu11)) {
  data <- extract_lu11[[name]]
  total_area <- length(data)
  count <- 0
  
  for (i in 1:length(lulc_idx)) {
    lc_count <- length(data[data == lulc_idx[i]])
    out <- ifelse(lc_count == 0, 0, -(lc_count/total_area)*log(lc_count/total_area))
    count <- count + out
  }
  
  final_cd_11[[name]] <- count  
}

final_2011 <- do.call(rbind, final_cd_11)
write.table(final_2011, file = "cd2011.txt", sep = " ", row.names=T, col.names=F)

#d = read.table("cd2001.txt", sep=" ", col.names=c("CTY_ID", "CROP_DIV"))

#stack three lists into single txt file (county, time)
#YYYY_DD_IDIDID
  

