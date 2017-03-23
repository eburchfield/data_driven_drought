library(raster)
library(ncdf4)
library(rslurm)

# setwd('/nfs/datadrivendroughteffect-data/data_driven_drought/tmp_danielle/')

var.name  <- 'ppt'
var.units <- 'mm/day'
mask.type <- 'ag'
mask.time <- 365
year.start <- 1981
year.end <- 2014
nyears <- year.end - year.start + 1
years <- seq(year.start, year.end, 1)
poly.order <- 1

slurm.params <- data.frame(year=years)

dir.daily <- '/nfs/datadrivendroughteffect-data/Data/PRISM/'
dir.mask <- '/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/'
tmpdir0 <- paste0('/tmp/', var.name, '_', mask.type)

# load mask brick
mask.nc <- nc_open(paste0(dir.mask, 'PRISM_', mask.time, '_', mask.type, '.nc'))
longitude <- ncvar_get(mask.nc, 'longitude')
latitude <- ncvar_get(mask.nc, 'latitude')
nlat <- length(latitude)
nlon <- length(longitude)

# reading in mask (365xlatxlon)
mask.year <- brick(paste0(dir.mask, 'PRISM_', mask.time, '_', mask.type, '.nc'))

# Create output nc file
# Create dimensions lon, lat, level and time
dim.lon  <- ncdim_def('longitude', 'degrees_east', longitude)
dim.lat  <- ncdim_def('latitude', 'degrees_north', latitude)
dim.time <- ncdim_def('year','year', years, unlim=T)

# Create a new variable "precipitation", create netcdf file, put updated contents on it and close file
# Note that variable "data" is the actual contents of the original netcdf file
#var.out <- ncvar_def(var.name, var.units, list(dim.lon,dim.lat,dim.time), -999)
var.out <- ncvar_def(var.name, var.units, list(dim.lon,dim.lat), -999)
file.nc <- paste0(dir.daily,'PRISM_annual_',var.name,'_',poly.order,'_',mask.type,'_',year.start,'-',year.end,'_TEST.nc')
nc.out <- nc_create(file.nc, var.out)
nc_close(nc.out)

calc_year_avg <- function(year) {

tmpdir <- paste(tmpdir0, year, sep='_')
rasterOptions(tmpdir=tmpdir)

# reading in variable (365xlatxlon)
var.year <- brick(paste0(dir.daily, 'PRISM_daily_', var.name, '_', year, '.nc'))

# masking variable using mask (365xlatxlon)
var.year.masked <- mask(subset(var.year, 1:mask.time), mask.year)

# performing operation (e.g. cubing) (365xlatxlon)
var.year.masked.poly <- var.year.masked**poly.order

# time average (1xlatxlon) 
var.year.avg <- calc(var.year.masked.poly,fun=mean,na.rm=TRUE)[,,1] 

#file.nc <- paste0(dir.daily,'PRISM_annual_',var.name,'_',poly.order,'_',mask.type,'_',year,'_TEST.nc')
#nc.out <- nc_create(file.nc, var.out)
#ncvar_put(nc.out, var.out, var.year.avg)
nc.out <- nc_open(file.nc)
year.ind <- which(years==year)
ncvar_put(nc.out, var.out, var.year.avg, start=c(1,1,year.ind), count=c(-1,-1,1))
nc_close(nc.out)

unlink(paste(tmpdir,'*',sep='/'))

} # calc_year_avg function

sopts <- list(partition="sesync")
#slurm.objects <- c('years', 'tmpdir0', 'var.out','var.name', 'poly.order', 'dir.daily', 'mask.time', 'mask.year', 'mask.type')
slurm.objects <- c('years', 'file.nc', 'tmpdir0', 'var.out','var.name', 'poly.order', 'dir.daily', 'mask.time', 'mask.year', 'mask.type')
sjob <- slurm_apply(calc_year_avg, slurm.params,
    nodes=5, cpus_per_node=8, submit=TRUE,         # 5 * 8 > nrow(slurm.params)
    add_objects=slurm.objects,
    slurm_options=sopts)
