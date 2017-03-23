library(raster)

dir.daily <- '/nfs/datadrivendroughteffect-data/Data/PRISM/'
var.name  <- 'tmean'

for (year in 1981:2015) {
rasterOptions(maxmemory = 1E7,
              tmpdir = "/nfs/datadrivendroughteffect-data/tmp")

# load a year brick
daily.year <- brick(paste(dir.daily,'PRISM_daily_',var.name,'_',year,'.nc',sep=''))
ndays <- daily.year@file@nbands
nweeks <- floor(ndays/7)
ndays.to.use <- nweeks*7
week.number.a <- seq(1,nweeks,1)
week.number.b <- matrix(rep(week.number.a,7),ncol=7)
week.number.c <- as.vector(t(week.number.b))

daily.year.to.use <- subset(daily.year,1:ndays.to.use)

weekly.year <- stackApply(daily.year.to.use,week.number.c,mean,na.rm=TRUE)

writeRaster(weekly.year,filename=paste(dir.daily,'PRISM_weekly_',var.name,'_',year,'.nc',sep=''),format='CDF',varname=var.name,bylayer=FALSE)

} # year loop
