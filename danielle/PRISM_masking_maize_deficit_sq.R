library(raster)
library(ncdf4)

dir.daily <- '/nfs/datadrivendroughteffect-data/Data/PRISM/'
dir.mask <- '/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/'
var.name  <- 'deficit'
var.units <- 'mm/day'
mask.type <- 'maize'
mask.time <- 365
year.start <- 1982
year.end <- 2014
nyears <- year.end-year.start+1
years <- seq(year.start,year.end,1)

tmpdir <- paste('/tmp/',var.name,'_',mask.type,sep='')

rasterOptions(tmpdir=tmpdir)

# load mask brick
mask.nc <- nc_open(paste(dir.mask,'PRISM_',mask.time,'_',mask.type,'.nc',sep=''))
longitude <- ncvar_get(mask.nc,'longitude')
latitude <- ncvar_get(mask.nc,'latitude')
nlat <- length(latitude)
nlon <- length(longitude)

mask.year <- brick(paste(dir.mask,'PRISM_',mask.time,'_',mask.type,'.nc',sep=''))

var.year.avg <- array(dim=c(nlat,nlon,nyears))

for (yy in 1:nyears) {
year <- years[yy]
print(year)

var.year <- brick(paste(dir.daily,'PRISM_30day_average_deficit_hamon_pet_',year,'.nc',sep=''))

var.year.masked <- mask(subset(var.year,1:mask.time),mask.year)
var.year.masked.sq <- var.year.masked**3
var.year.avg[,,yy] <- calc(var.year.masked.sq,fun=mean,na.rm=TRUE)[,,1] 

unlink(paste(tmpdir,'*',sep='/'))

} # year loop

# Create dimensions lon, lat, level and time
dim.lon  <- ncdim_def('longitude', 'degrees_east', longitude)
dim.lat  <- ncdim_def('latitude', 'degrees_north', latitude)
dim.time <- ncdim_def('year','year', years, unlim=T)

# Create a new variable "precipitation", create netcdf file, put updated contents on it and close file
# Note that variable "data" is the actual contents of the original netcdf file
var.out <- ncvar_def(var.name, var.units, list(dim.lon,dim.lat,dim.time), -999)
nc.out <- nc_create(paste(dir.daily,'PRISM_annual_',var.name,'_cubed_',mask.type,'_',year.start,'-',year.end,'.nc',sep=''), var.out)
ncvar_put(nc.out, var.out, var.year.avg)
nc_close(nc.out)

unlink(paste(tmpdir,'*',sep='/'))

