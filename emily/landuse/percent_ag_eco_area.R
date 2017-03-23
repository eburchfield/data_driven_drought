library(rgdal)
library(raster)

#data prep

#ndvi reference layer
ndvi_list <- Sys.glob(paste('/nfs/datadrivendroughteffect-data/Data/NDVI/',"*",'ndvi_final.tif',sep=""))  #n = 1373
ndvi <- raster(ndvi_list[1])

#county shapefile
shp_dr <- '/nfs/datadrivendroughteffect-data/Data/County_shp/cb_2015_us_county_500k.shp'
shp_data <- readOGR(dsn=shp_dr, layer = "cb_2015_us_county_500k", stringsAsFactors=F)
shp_data <- spTransform(shp_data, projection(ndvi))

#land use raster
lu <- raster("lulc_bin.tif")

#extract landuse by county
extract_lu <- extract(lu, shp_data, na.rm=T) #shp
names(extract_lu) <- shp_data$ID #shp

final_ag <- list()
final_eco <- list()

#loop through counties
for (name in names(extract_lu)) {
  data <- extract_lu[[name]]
  total_area <- length(data)
  ag <- length(data[data == 2])
  eco <- length(data[data == 1])
  final_ag[[name]] <- (ag/total_area)*100
  final_eco[[name]] <- (eco/total_area)*100
}

final_ag <- do.call(rbind, final_ag)  
final_eco <- do.call(rbind, final_eco)

write.table(final_ag, file = "percent_ag_cty.txt", sep = " ", row.names=T, col.names=F)
write.table(final_eco, file = "percent_eco_cty.txt", sep = " ", row.names=T, col.names=F)

#d = read.table("percent_eco_cty.txt", sep=" ", col.names=c("CTY_ID", "PERC_AG"))

#stack three lists into single txt file (county, time)
#YYYY_DD_IDIDID


#county raster
extent(ndvi) <- extent(shp_data)
cty_ras <- rasterize(shp_data, ndvi, 'ID')
writeRaster(cty_ras, '/nfs/datadrivendroughteffect-data/Data/County_shp/cty_id_raster.tif')

test <- raster('/nfs/datadrivendroughteffect-data/Data/County_shp/cty_id_raster.tif')
