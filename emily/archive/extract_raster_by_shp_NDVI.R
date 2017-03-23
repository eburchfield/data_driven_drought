library(rgdal)
library(raster)
library(ncdf4)
library(rslurm)

#wheat, soy, maize, eco

#objects
data_list <- Sys.glob(paste('/nfs/datadrivendroughteffect-data/Data/NDVI/',"*",'wheat.tif',sep=""))
shp_data <- shapefile('/nfs/datadrivendroughteffect-data/Data/County_shp/cty_ndvi_proj.shp')

#subset_test
#data_list <- data_list[1:2] #reomve

extract_data <- function(i) {
  
  #shp_data <- shp_data[shp_data$STATEFP == '46',] #remove

  rasterOptions(tmpdir = "/nfs/datadrivendroughteffect-data/raster_tmp")

  name <- data_list[i]
  raster_data <- brick(name)
  #raster_data <- crop(raster_data, shp_data) #remove
  #raster_data <- raster_data[[22:23]] #remove
  year <- substr(name, 50, 53)

  all_data <- list()

  for (b in 1:nlayers(raster_data)) {
    
    doy_data <- extract(raster_data[[b]], shp_data, na.rm=T)
    doy_summary <- list()
    week <- b
    
    for (name in 1:length(doy_data)) {
      mn <- mean(doy_data[[name]], na.rm=T) 
      cty_list <- c(year, week, mn)
      doy_summary[[name]] <- cty_list
    }
    
    doy_summary_df <- do.call(rbind, doy_summary) 
    doy_summary_df <- cbind(shp_data$STATEFP, shp_data$COUNTYFP, doy_summary_df)
    colnames(doy_summary_df) <- c("STATEFP", "COUNTYFP", "YEAR", "WEEK", "MEAN")
    all_data[[b]] <- doy_summary_df
  }                      
  
  final_data <- do.call(rbind, all_data)  
  
  return(final_data)
}

params <- data.frame(i = seq_along(data_list))
sjob <- slurm_apply(extract_data, params, nodes = 10, cpus_per_node = 8,
                    add_objects = c("data_list", "shp_data"), 
                    slurm_options = list(partition = "sesync"))


print_job_status(sjob)
res <- get_slurm_out(sjob, "table")
out_data <- as.data.frame(res)


write.table(out_data, file = "/nfs/datadrivendroughteffect-data/Data/NDVI/NDVI_county_mean_quantile.csv", 
            sep = ",", col.names = TRUE)
#test <- read.csv("/nfs/datadrivendroughteffect-data/Data/NDVI/NDVI_county_mean_quantile.csv", sep=",", row.names=NULL)
#cleanup_files(sjob)