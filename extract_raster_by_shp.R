library(rgdal)
library(raster)

#space-time resolution
#obs_per_year = 52; 
#missing data flag

#dataset paths
data_dr <- '/nfs/datadrivendroughteffect-data/Data/NDVI/'
data_ex <- 'ndvi.tif'
shp_dr <- '/nfs/datadrivendroughteffect-data/Data/cb_2015_us_county_500k.shp'

#data prep
data_list <- Sys.glob(paste(data_dr,"*",data_ex,sep=""))
raster_data <- raster(data_list[100])
shp_data <- readOGR(dsn=shp_dr, layer = "cb_2015_us_county_500k", stringsAsFactors=F)
shp_data <- spTransform(counties, projection(raster_data))

#scale function
rescale <- function(x, x.min = NULL, x.max = NULL, new.min = 0, new.max = 1) {
  if(is.null(x.min)) x.min = cellStats(x, "min")
  if(is.null(x.max)) x.max = cellStats(x, "max")
  new.min + (x - x.min) * ((new.max - new.min) / (x.max - x.min))
}

raster_data <- rescale(raster_data, x.min = 0, x.max = 200, new.min = -1, new.max = 1)

#extract data
extract_data <- extract(raster_data, shp_data)
names(extract_data) <- shp_data$ID
#591 secs
#all cells with center in polygon are fully counted in, other cells are out
#to change, extract(raster1, vector_layer, fun=mean, weights=TRUE); takes more time

#compute mean for polygon
mn <- list()
sd <- list()

for (name in names(extract_data)) {
  mn_cty <- mean(extract_data[[name]], na.rm=T)
  sd_cty <- sd(extract_data[[name]], na.rm=T)
  mn[[name]] <- mn_cty
  sd[[name]] <- sd_cty
  
}


