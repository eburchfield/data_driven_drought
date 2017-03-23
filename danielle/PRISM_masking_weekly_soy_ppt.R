library(raster)
library(ncdf4)

rasterOptions(tmpdir = "/nfs/datadrivendroughteffect-data/raster_tmp")

dir.daily <- '/nfs/datadrivendroughteffect-data/Data/PRISM/'
dir.mask <- '/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/'
var.name  <- 'ppt'
var.units <- 'mm/day'
mask.type <- 'soy'
mask.time <- 'weekly'
nweeks <- 52
year.start <- 1981
year.end <- 2015
nyears <- year.end-year.start+1
years <- seq(year.start,year.end,1)

# load mask brick
mask.nc <- nc_open(paste(dir.mask,'PRISM_',mask.time,'_',mask.type,'.nc',sep=''))
longitude <- ncvar_get(mask.nc,'longitude')
latitude <- ncvar_get(mask.nc,'latitude')
nlat <- length(latitude)
nlon <- length(longitude)

mask.year <- brick(paste(dir.mask,'PRISM_',mask.time,'_',mask.type,'.nc',sep=''))

for (yy in 1:nyears) {
year <- years[yy]
print(year)

var.year <- brick(paste(dir.daily,'PRISM_weekly_',var.name,'_',year,'.nc',sep=''))

var.year.masked <- mask(var.year,mask.year)
var.year.masked.array <- as.array(var.year.masked)

# Create dimensions lon, lat, level and time
dim.lon  <- ncdim_def('longitude', 'degrees_east', longitude)
dim.lat  <- ncdim_def('latitude', 'degrees_north', latitude)
dim.time <- ncdim_def('week','week', seq(1,nweeks,1))

var.out <- ncvar_def(var.name, var.units, list(dim.lon,dim.lat,dim.time), -999)
nc.out <- nc_create(paste(dir.daily,'PRISM_weekly_',var.name,'_',mask.type,'_',year,'.nc',sep=''), var.out)
ncvar_put(nc.out, var.out, var.year.masked.array)
nc_close(nc.out)

} # year loop



