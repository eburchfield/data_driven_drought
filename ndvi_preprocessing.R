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

