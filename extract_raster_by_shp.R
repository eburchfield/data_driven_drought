library(rgdal)
library(raster)
library(ncdf4)
library(rslurm)

#objects
data_list <- Sys.glob(paste('/nfs/datadrivendroughteffect-data/Data/NDVI/',"*",'ndvi_final.tif',sep=""))
shp_data <- shapefile('/nfs/datadrivendroughteffect-data/Data/County_shp/cty_ndvi_proj.shp')
ag_mask <- raster('/nfs/datadrivendroughteffect-data/Data/Landuse/ag_mask.tif/')
eco_mask <- raster('/nfs/datadrivendroughteffect-data/Data/Landuse/eco_mask.tif')

extract_data <- function(i) {

  rasterOptions(tmpdir = "/nfs/datadrivendroughteffect-data/raster_tmp")
  name <- data_list[i]
  raster_data <- raster(name)

  #extract date info 
  year <- as.numeric(substr(name, 51, 52))
  year <- ifelse(year > 17, paste("19", year, sep=""), paste("20", year, sep=""))
  doy <- format(strptime(substr(name, 54, 56), format="%j"), format="%m-%d") 
  month <- substr(doy,0,2)
  day <- substr(doy,4,5)
  
  #extract ag/eco pixels
  ag_data <- extract(mask(raster_data, ag_mask), shp_data, na.rm=T)  
  names(ag_data) <- shp_data$ID
  eco_data <- extract(mask(raster_data, eco_mask), shp_data, na.rm=T)  
  names(eco_data) <- shp_data$ID
  
  final_ag <- list()
  final_eco <- list()
  
  for (name in names(ag_data)) {
    qt <- quantile(ag_data[[name]], probs = seq(0, 1, 0.05), na.rm = T)
    mn <- mean(ag_data[[name]], na.rm=T) 
    names(mn) <- "mean_ag"
    names(day) <- "day"
    cty_list <- c(day, mn, qt)
    final_ag[[name]] <- cty_list
    
    qt_e <- quantile(eco_data[[name]], probs = seq(0, 1, 0.05), na.rm = T)
    mn_e <- mean(eco_data[[name]], na.rm=T) 
    names(mn_e) <- "mean_eco"
    cty_list_e <- c(mn_e, qt_e)
    final_eco[[name]] <- cty_list_e
  }
  
  final_ag_data = do.call(rbind, final_ag)  
  final_eco_data = do.call(rbind, final_eco)  
  final_data = cbind(final_ag_data, final_eco_data)
  row.names(final_data) <- paste(year, "_", month, "_",row.names(final_data), sep="")
  
  return(final_data)
  
}

params <- data.frame(i = seq_along(data_list))
sjob <- slurm_apply(extract_data, params, nodes = 10, cpus_per_node = 8,
                    add_objects = c("data_list", "shp_data", "ag_mask", "eco_mask"), 
                    slurm_options = list(partition = "sesync"))


print_job_status(sjob)
res <- get_slurm_out(sjob, "table")
out_data <- as.data.frame(res)
write.table(out_data, file = "/nfs/datadrivendroughteffect-data/Data/NDVI/county_mean_quantile.csv", 
            sep = ",", col.names = TRUE)
#test <- read.csv("/nfs/datadrivendroughteffect-data/Data/NDVI/county_mean_quantile.csv", sep=",", row.names=NULL)
#cleanup_files(sjob)