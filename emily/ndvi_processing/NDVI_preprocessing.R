library(rgdal)
library(raster)

#Lambert Azimuthal Equal Area

#load data
data_dr <- '/nfs/datadrivendroughteffect-data/Data/NDVI/'
data_ex <- 'ndvi.tif'
data_list <- Sys.glob(paste(data_dr,"*",data_ex,sep=""))  #n = 1373

# for (i in 1:length(data_list)) {
#   
#   #load data
#   fn <- data_list[i]
#   out_fn <- paste(str_sub(data_list[i], 1,-5),"_final.tif",sep="")
#   r <- raster(fn)
#   
#   #values greater than 200 NA; see dataset documentation
#   r[r > 200] <- NA
#   
#   #rescaling from -1 to 1; see dataset documentation
#   r <- (r - 100)/100  
#   
#   #write out raster
#   writeRaster(r, out_fn)
#   print(paste0("Saved raster: ", out_fn))
# }

#remove_list <- Sys.glob(paste(data_dr,"*ndvi.tfw",sep=""))  #all files with "date"

#create annual data cubes and masks

#annual datacube
data_list <- Sys.glob(paste('/nfs/datadrivendroughteffect-data/Data/NDVI/',"*",'ndvi_final.tif',sep=""))
data_list <- data_list[1:1404]
year_start <- seq(from=1, to=1404, by=52)
years <- seq(from=1989, to=2015, by=1)

for (i in 1:26) {
  stop <- year_start[i+1] - 1
  dl_subset <- data_list[year_start[i]:stop]
  ndvi_brick <- stack(dl_subset)
  fn <- paste('/nfs/datadrivendroughteffect-data/Data/NDVI/ndvi_', years[i],"_dc.tif", sep="")
  writeRaster(ndvi_brick, fn, overwrite=T)
}

dl_subset <- data_list[1353:1404]
ndvi_brick <- stack(dl_subset)
writeRaster(ndvi_brick, paste('/nfs/datadrivendroughteffect-data/Data/NDVI/ndvi_2015_dc.tif', sep=""))


#land use fraction 
wheat_lulc <- brick("/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/PRISM_weekly_wheat_frac.nc")
soy_lulc <- brick("/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/PRISM_weekly_soy_frac.nc")
maize_lulc <- brick("/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/PRISM_weekly_maize_frac.nc")
eco_lulc <- brick("/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/PRISM_weekly_eco.nc")

wheat_lulc <- projectRaster(wheat_lulc, crs = ndvi@crs, method="bilinear")
soy_lulc <- projectRaster(soy_lulc, crs=ndvi@crs, method="bilinear")
maize_lulc <- projectRaster(maize_lulc, crs=ndvi@crs, method="bilinear")
eco_lulc <- projectRaster(eco_lulc, crs=ndvi@crs, method="ngb") #categorical

wheat_mask <- resample(wheat_lulc, ndvi) ### TAKES TIME
soy_mask <- resample(soy_lulc, ndvi)
maize_mask <- resample(maize_lulc, ndvi)
eco_mask <- resample(eco_lulc, ndvi, method="ngb")

#writeRaster(wheat_mask, '/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/NDVI_weekly_wheat_frac.nc', format="CDF")
writeRaster(soy_mask, '/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/NDVI_weekly_soy_frac.nc', format="CDF")
writeRaster(maize_mask, '/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/NDVI_weekly_maize_frac.nc', format="CDF")
writeRaster(eco_mask, '/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/NDVI_weekly_eco_frac.nc', format="CDF")


#apply masks to dataset
data_list <- Sys.glob(paste('/nfs/datadrivendroughteffect-data/Data/NDVI/',"*",'dc.tif',sep=""))

for (i in 1:length(data_list)) {
  ndvi_brick <- brick(data_list[i])
  ndvi_wheat <- ndvi_brick*wheat_mask
  ndvi_soy <- ndvi_brick*soy_mask
  ndvi_maize <- ndvi_brick*maize_mask
  ndvi_eco <- ndvi_brick*eco_mask
  writeRaster(ndvi_wheat, paste('/nfs/datadrivendroughteffect-data/Data/NDVI/ndvi_', years[i],"_wheat.tif", sep=""), overwrite=T)
  writeRaster(ndvi_soy, paste('/nfs/datadrivendroughteffect-data/Data/NDVI/ndvi_', years[i],"_soy.tif", sep=""), overwrite=T)
  writeRaster(ndvi_maize, paste('/nfs/datadrivendroughteffect-data/Data/NDVI/ndvi_', years[i],"_maize.tif", sep=""), overwrite=T)
  writeRaster(ndvi_eco, paste('/nfs/datadrivendroughteffect-data/Data/NDVI/ndvi_', years[i],"_eco.tif", sep=""), overwrite=T)
}


test <- brick('/nfs/datadrivendroughteffect-data/Data/NDVI/ndvi_2015_wheat.tif')

ndvi_wheat <- mask()

