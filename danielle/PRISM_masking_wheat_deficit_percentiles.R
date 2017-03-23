library(raster)
library(ncdf4)

rasterOptions(tmpdir='/tmp/danielle')

dir.daily <- '/nfs/datadrivendroughteffect-data/Data/PRISM/'
dir.mask <- '/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/'
var.name  <- 'deficit'
var.units <- 'mm/day'
mask.type <- 'wheat'
mask.time <- 365
year.start <- 1982
year.end <- 2014
nyears <- year.end-year.start+1
years <- seq(year.start,year.end,1)
percentiles <- c(0,0.02,0.05,0.1,0.2,0.3,0.5,0.7,0.8,0.9,0.95,0.98,1)

tmpdir <- paste('/tmp/',var.name,'_',mask.type,sep='')
rasterOptions(tmpdir=tmpdir)

# load mask brick
mask.nc <- nc_open(paste(dir.mask,'PRISM_',mask.time,'_',mask.type,'.nc',sep=''))
longitude <- ncvar_get(mask.nc,'longitude')
latitude <- ncvar_get(mask.nc,'latitude')
nlat <- length(latitude)
nlon <- length(longitude)

mask.year <- brick(paste(dir.mask,'PRISM_',mask.time,'_',mask.type,'.nc',sep=''))
mask.npixels <- length(which(!is.na(as.array(mask.year))))
var.keep <- array(dim=(mask.npixels*nyears)) 

for (yy in 1:nyears) {
year <- years[yy]
print(year)

var.year <- brick(paste(dir.daily,'PRISM_30day_average_deficit_hamon_pet_',year,'.nc',sep=''))

var.year.masked <- mask(subset(var.year,1:mask.time),mask.year)
var.year.array <-as.array(var.year.masked)
var.year.keep <- which(!is.na(var.year.array))
nkeep <- length(var.year.keep)
start.array <- (yy-1)*mask.npixels+1
var.keep[start.array:(start.array+nkeep-1)] <- var.year.array[var.year.keep]

unlink(paste(tmpdir,'*',sep='/'))

} # year loop

var.percentiles <- quantile(var.keep,prob=percentiles,na.rm=TRUE)

saveRDS(var.percentiles,file=paste(dir.daily,'PRISM_annual_',var.name,'_percentiles_',mask.type,'_',year.start,'-',year.end,'.rds',sep=''))

unlink(paste(tmpdir,'*',sep='/'))

