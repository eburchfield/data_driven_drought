library(rgdal)
library(raster)
library(ncdf4)

ds <- read.csv("/nfs/datadrivendroughteffect-data/Data/NDVI/county_mean_quantile_year.csv", sep=",", row.names=NULL, stringsAsFactors = F)
data_list <- Sys.glob(paste('/nfs/datadrivendroughteffect-data/Data/NDVI/',"*",'ndvi_final.tif',sep=""))
ref <- raster(data_list[1])
ref <- setValues(ref, NA)

#fix in dataset
ds$V1[ds$V1 == 200] <- 2000
ds$V1[ds$V1 == 201] <- 2001
ds$V1[ds$V1 == 202] <- 2002
ds$V1[ds$V1 == 203] <- 2003
ds$V1[ds$V1 == 204] <- 2004
ds$V1[ds$V1 == 205] <- 2005
ds$V1[ds$V1 == 206] <- 2006
ds$V1[ds$V1 == 207] <- 2007
ds$V1[ds$V1 == 208] <- 2008
ds$V1[ds$V1 == 209] <- 2009


doy_list <- list()
for (i in 1:length(data_list)) {
  doy <- unlist(strsplit(substr(data_list[i], 51, 56), "_"))
  year <- as.numeric(doy[1])
  names(year) <- "year"
  day <- as.numeric(doy[2])
  names(day) <- "day"
  doy_list[[i]] <- c(year, day)
}
doy <- as.data.frame(do.call(rbind, doy_list))

#89, 51 - OK
#start:4
d89 <- doy$day[doy$year == 89]
d89 <- c(d89, NA) #add one NA at the end

fn_89_01 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us89_068071_ndvi_final.tif"
writeRaster(ref, filename=fn_89_01, format="GTiff")

#90, 36 - OK
#start:3
#compare to y97
d90 <- doy$day[doy$year == 90]
d90 <- c(3, 10, 17, 24, 31, 38, 45, 52, 61, NA, 75, NA, 89, NA, 103, NA, 117, NA, NA, 131, NA,
         145, NA, 159, NA, 173, NA, 187, NA, 201, NA, 215, NA, 229, NA, 243, NA, 257, NA, 271,
         285, 292, 299, 306, 313, 320, 327, 334, 341, 348, 355, 361)


fn_90_68 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us90_068070_ndvi_final.tif"
writeRaster(ref, filename=fn_90_68, format="GTiff")

fn_90_80 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us90_080085_ndvi_final.tif"
writeRaster(ref, filename=fn_90_80, format="GTiff")

fn_90_95 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us90_095097_ndvi_final.tif"
writeRaster(ref, filename=fn_90_95, format="GTiff")

fn_90_108 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us90_108113_ndvi_final.tif"
writeRaster(ref, filename=fn_90_108, format="GTiff")

fn_90_121 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us90_121125_ndvi_final.tif"
writeRaster(ref, filename=fn_90_121, format="GTiff")

fn_90_126 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us90_126130_ndvi_final.tif"
writeRaster(ref, filename=fn_90_126, format="GTiff")

fn_90_136 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us90_136141_ndvi_final.tif"
writeRaster(ref, filename=fn_90_136, format="GTiff")

fn_90_150 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us90_150155_ndvi_final.tif"
writeRaster(ref, filename=fn_90_150, format="GTiff")

fn_90_161 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us90_161170_ndvi_final.tif"
writeRaster(ref, filename=fn_90_161, format="GTiff")

fn_90_177 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us90_177180_ndvi_final.tif"
writeRaster(ref, filename=fn_90_177, format="GTiff")

fn_90_190 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us90_190195_ndvi_final.tif"
writeRaster(ref, filename=fn_90_190, format="GTiff")

fn_90_206 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us90_206212_ndvi_final.tif"
writeRaster(ref, filename=fn_90_206, format="GTiff")

fn_90_220 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us90_220225_ndvi_final.tif"
writeRaster(ref, filename=fn_90_220, format="GTiff")

fn_90_230 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us90_230235_ndvi_final.tif"
writeRaster(ref, filename=fn_90_230, format="GTiff")

fn_90_250 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us90_250256_ndvi_final.tif"
writeRaster(ref, filename=fn_90_250, format="GTiff")

fn_90_260 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us90_260265_ndvi_final.tif"
writeRaster(ref, filename=fn_90_260, format="GTiff")


#91, 52 - OK
#start:4
d91 <- doy$day[doy$year == 91]

#92, 53 - OK
#start:3
d92 <- doy$day[doy$year == 92]
d92 <- head(d92, -1)  #drop last entry, 361, removed file

#93, 52 - OK
#start:1
d93 <- doy$day[doy$year == 93]

#94, 37 - OK
#start:7
#compare to y14, many missing at end
d94 <- doy$day[doy$year == 94]
d94 <- head(d94, -1) #drop 365
d94 <- c(d94, rep(NA, 15), 365)

fn_94_253 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us94_253254_ndvi_final.tif"
writeRaster(ref, filename=fn_94_253, format="GTiff")

fn_94_255 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us94_255256_ndvi_final.tif"
writeRaster(ref, filename=fn_94_255, format="GTiff")

fn_94_257 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us94_257258_ndvi_final.tif"
writeRaster(ref, filename=fn_94_257, format="GTiff")

fn_94_259 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us94_259260_ndvi_final.tif"
writeRaster(ref, filename=fn_94_259, format="GTiff")

fn_94_261 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us94_261262_ndvi_final.tif"
writeRaster(ref, filename=fn_94_261, format="GTiff")

fn_94_263 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us94_263264_ndvi_final.tif"
writeRaster(ref, filename=fn_94_263, format="GTiff")

fn_94_265 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us94_265266_ndvi_final.tif"
writeRaster(ref, filename=fn_94_265, format="GTiff")

fn_94_267 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us94_267268_ndvi_final.tif"
writeRaster(ref, filename=fn_94_267, format="GTiff")

fn_94_269 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us94_269270_ndvi_final.tif"
writeRaster(ref, filename=fn_94_269, format="GTiff")

fn_94_271 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us94_271272_ndvi_final.tif"
writeRaster(ref, filename=fn_94_271, format="GTiff")

fn_94_273 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us94_273274_ndvi_final.tif"
writeRaster(ref, filename=fn_94_273, format="GTiff")

fn_94_275 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us94_275276_ndvi_final.tif"
writeRaster(ref, filename=fn_94_275, format="GTiff")

fn_94_277 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us94_277278_ndvi_final.tif"
writeRaster(ref, filename=fn_94_277, format="GTiff")

fn_94_279 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n11_us94_279230_ndvi_final.tif"
writeRaster(ref, filename=fn_94_279, format="GTiff")


#95, 49 - OK
#start:20
#compare to y09, missing at beginning and end
d95 <- doy$day[doy$year == 95]
d95 <- c(rep(NA, 2), d95, NA)

fn_95_001 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n14_us95_001010_ndvi_final.tif"
writeRaster(ref, filename=fn_95_001, format="GTiff")

fn_95_011 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n14_us95_011015_ndvi_final.tif"
writeRaster(ref, filename=fn_95_011, format="GTiff")

fn_95_360 <- "/nfs/datadrivendroughteffect-data/Data/NDVI/n14_us95_360365_ndvi_final.tif"
writeRaster(ref, filename=fn_95_360, format="GTiff")


#96, 52
#start:5
d96 <- doy$day[doy$year == 96]

#97, 52
#start:3
d97 <- doy$day[doy$year == 97]

#98, 53 - OK
#start:2
d98 <- doy$day[doy$year == 98]
d98 <- head(d98, -1)  #drop last entry, 360, removed file

#99, 52 - OK
#start:1
d99 <- doy$day[doy$year == 99]

#00, 52 - OK
#start:7
d00 <- doy$day[doy$year == 00]

#01, 52 - OK
#start:5
d01 <- doy$day[doy$year == 01]

#02, 52 - OK
#start:4
d02 <- doy$day[doy$year == 02]

#03, 52
#start:1
d03 <- doy$day[doy$year == 03]
d03 <- head(d03, -1)  #drop last entry, 361, removed file

#04, 52 - OK
#start:7
d04 <- doy$day[doy$year == 04]

#05, 52 - OK
#start:5
d05 <- doy$day[doy$year == 05]

#06, 52 - OK
#start:4
d06 <- doy$day[doy$year == 06]

#07, 52 - OK
#start:2
d07 <- doy$day[doy$year == 07]

#08, 52 - OK
#start:1
d08 <- doy$day[doy$year == 08]

#09, 52 - OK
#start:6
d09 <- doy$day[doy$year == 09]

#10, 52 - OK
#start:5
d10 <- doy$day[doy$year == 10]

#11, 52- OK
#start:4
d11 <- doy$day[doy$year == 11]

#12, 52 - OK
#start:3
d12 <- doy$day[doy$year == 12]

#13, 52 - OK
#start:1
d13 <- doy$day[doy$year == 13]

#14, 52 - OK
#start:7
d14 <- doy$day[doy$year == 14]

#15, 52 - OK
#start:6
d15 <- doy$day[doy$year == 15]


#years <- c(89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 00, 01, 02, 03, 04, 05, 06,
#           07, 08, 09, 10, 11, 12, 13, 14, 15)

#create ideal date sequence:
years <- seq(from=1989, to=2015, by=1)
final_year <- cbind(rep(years, each=52))
final_day <- c(d89, d90, d91, d92, d93, d94, d95, d96, d97, d98, d99, d00, d01, d02, d03, d04, d05, d06,
               d07, d08, d09, d10, d11, d12, d13, d14, d15)
final_dates <- as.data.frame(cbind(final_year, final_day))
names(final_dates) <- c("year", "day")

#insertRow function:
insertRow <- function(existingDF, newrow, r) {
  existingDF[seq(r+1,nrow(existingDF)+1),] <- existingDF[seq(r,nrow(existingDF)),]
  existingDF[r,] <- newrow
  existingDF
}

#where final_dates missing, insert final_date n=3108 times
ds_sub <- ds[sample(nrow(ds), 0.001*nrow(ds)), ] 
observed_dates <- unique(ds_sub[c("V1", "day")])
observed_dates <- observed_dates[with(observed_dates, order(V1, day)), ]

#day, month to DOY


for (i in 1:nrow(ds_sub)) {
  
  
}


#3108 counties
which(is.na(final_dates))
ds_full <- insertRow(ds, rep(NA, 46), (n*3108):(n*3108)+3108)



#loop through full list of dates
#if year_doy in full list, append data, else insert NAs

#3108 * 1404




#other code used:

# year_list <- list()
# for (i in 1:nrow(ds)) {
#   doy <- unlist(strsplit(ds$row.names[i], "_"))
#   year <- as.numeric(doy[1])
#   year_list[[i]] <- year
# }
# all_years <- as.data.frame(do.call(rbind, year_list))

#append year to ds dataset
#dsf <- cbind(ds, all_years)
#write.table(dsf, file = "/nfs/datadrivendroughteffect-data/Data/NDVI/county_mean_quantile_year.csv", 
#            sep = ",", col.names = TRUE, row.names = FALSE)

#month column

month_list <- list()
for (i in nrow(ds)) {
  doy <- unlist(strsplit(ds$row.names[i], "_"))
  month <- as.numeric(doy[2])
  month_list[[i]] <- month
}
all_months <- as.data.frame(do.call(rbind, month_list))

#wherever there's a NA, insert 3108 rows in original dataset



