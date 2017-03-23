library(raster)
library(ncdf4)

string_list <-c('ag_frac','eco_frac','maize_frac','soy_frac','wheat_frac' )
for (i in string_list){
# specify directory for temp data
rasterOptions(tmpdir = "/nfs/datadrivendroughteffect-data/raster_tmp")

# specify directories for data
dir.daily <- '/nfs/datadrivendroughteffect-data/Data/soil_moisture/modeled_soil_moisture/'
dir.mask <- '/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/'

# specify type of data being masked
var.name  <- 'soilmoisture'
var.units <- 'mm/day'

# specify type of mask
mask.type <- i
mask.time <- 'monthly'
year.start <- 1991
year.end <- 2015
nyears <- year.end-year.start+1
years <- seq(year.start,year.end,1)

# load mask file using nc_open and read in mask dimensions (so that you can use the ncdf4 package to write out your output file)
mask.nc <- nc_open(paste(dir.mask,'NLDAS_',mask.time,'_',mask.type,'.nc',sep=''))
longitude <- ncvar_get(mask.nc,'longitude')
latitude <- ncvar_get(mask.nc,'latitude')
nlat <- length(latitude)
nlon <- length(longitude)

# read mask for one year as a raster (so that you can use the raster package for masking)
mask.year <- brick(paste(dir.mask,'NLDAS_',mask.time,'_',mask.type,'.nc',sep=''))

# create an array for your output. This is nlat x nlon x nyears array, where each grid point gets one value per year (ie a weighted-average soil moisture value with the weights depending on the growing season during the year)
var.year.avg <- array(dim=c(nlat,nlon,nyears))

# read in soil moisutre data for whole period
var.all <- brick(paste(dir.daily,'merged_clipped.nc',sep=''))

# loop through years to mask each year
for (yy in 1:nyears) {
year <- years[yy]
print(year)

#subset yearly data using raster package subset function
var.year <- subset(var.all,((yy-1)*12+1):(yy*12)) 

#mask yearly data with fraction using raster package. Basically the overlay function lets you take two or more rasters and create a new raster using a user-defined function/operator between the input rasters
var.year.frac <-  overlay(var.year, mask.year, fun=function(x,y){(x*y)} ) 

# average the 3d raster go get a 2d lat x lon raster. the calc function in the raster package allows you to apply a function across a dimension in a raster
var.year.avg[,,yy] <- calc(var.year.frac,fun=mean,na.rm=TRUE)[,,1] 

} # year loop

# Create nc file for all years with one layer per year
# create dimensions for file
dim.lon  <- ncdim_def('longitude', 'degrees_east', longitude)
dim.lat  <- ncdim_def('latitude', 'degrees_north', latitude)
dim.time <- ncdim_def('year','year', years, unlim=T)

# just more netcdf writing stuff: specifying file name, variable name, units and dimensions 
var.out <- ncvar_def(var.name, var.units, list(dim.lon,dim.lat,dim.time), -999)
nc.out <- nc_create(paste(dir.daily,'NLDAS_annual_',var.name,'_',mask.type,'_',year.start,'-',year.end,'.nc',sep=''), var.out)
ncvar_put(nc.out, var.out, var.year.avg)
nc_close(nc.out)
}
