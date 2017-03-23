library(raster)
library(ncdf4)

rasterOptions(tmpdir='/tmp/danielle')

dir.daily <- '/nfs/datadrivendroughteffect-data/Data/PRISM/'
dir.mask <- '/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/'
var.name  <- 'ppt'
var.units <- 'mm/day'
mask.type <- 'ag'
mask.time <- 365
year.start <- 1981
year.end <- 2015
nyears <- year.end-year.start+1
years <- seq(year.start,year.end,1)
percentiles <- c(0,0.02,0.05,0.1,0.2,0.3,0.5,0.7,0.8,0.9,0.95,0.98,1)
nbins <- length(percentiles)-1

# load percentile values
perc.vals <- readRDS(file=paste(dir.daily,'PRISM_annual_',var.name,'_percentiles_',mask.type,'_',year.start,'-',year.end,'.rds',sep=''))

# load mask brick
mask.nc <- nc_open(paste(dir.mask,'PRISM_',mask.time,'_',mask.type,'.nc',sep=''))
longitude <- ncvar_get(mask.nc,'longitude')
latitude <- ncvar_get(mask.nc,'latitude')
nlat <- length(latitude)
nlon <- length(longitude)

mask.year <- brick(paste(dir.mask,'PRISM_',mask.time,'_',mask.type,'.nc',sep=''))

var.year.avg <- array(dim=c(nlat,nlon,nyears,nbins))

for (yy in 1:nyears) {
year <- years[yy]
print(year)

var.year <- brick(paste(dir.daily,'PRISM_daily_',var.name,'_',year,'.nc',sep=''))

var.year.masked <- mask(subset(var.year,1:mask.time),mask.year)

for (bb in 1:nbins) {
var.year.masked.bin <- var.year.masked
var.year.masked.bin[var.year.masked>=perc.vals[bb]&var.year.masked<perc.vals[bb+1]] <- NA 
var.year.avg[,,yy,bb] <- calc(var.year.masked.bin,fun=mean,na.rm=TRUE)[,,1] 
}

unlink('/tmp/danielle/*')

} # year loop

# Create dimensions lon, lat, level and time
dim.lon  <- ncdim_def('longitude', 'degrees_east', longitude)
dim.lat  <- ncdim_def('latitude', 'degrees_north', latitude)
dim.time <- ncdim_def('year','year', years, unlim=T)

# Create a new variable "precipitation", create netcdf file, put updated contents on it and close file
# Note that variable "data" is the actual contents of the original netcdf file
var.out <- ncvar_def(var.name, var.units, list(dim.lon,dim.lat,dim.time), -999)
for (bb in 1:nbins) {
nc.out <- nc_create(paste(dir.daily,'PRISM_annual_',var.name,'_cubed_',mask.type,'_',year.start,'-',year.end,'_bin_',bb,'.nc',sep=''), var.out)
ncvar_put(nc.out, var.out, var.year.avg)
nc_close(nc.out)


