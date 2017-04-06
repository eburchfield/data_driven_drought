library(raster)

#https://earlywarning.usgs.gov/USirrigation
#ENVI 1 km downloaded

# load ag mask and county data

shp_data <- shapefile('/nfs/datadrivendroughteffect-data/Data/County_shp/cty_ndvi_proj.shp')
ag <- raster('/nfs/datadrivendroughteffect-data/Data/Landuse/ag_mask.tif')

# change flag 2 to flag 1 for summing function

ag[ag==2] <- 1 

# load irrigation data, MIRAD 1 km

y02 <- raster('/nfs/datadrivendroughteffect-data/Data/Irrigation/mirad1k_02v3_bsq/mirad1k_02v3envi.bsq')
y07 <- raster('/nfs/datadrivendroughteffect-data/Data/Irrigation/mirad1k_07v3_bsq/mirad1k_07v3envi.bsq')
y12 <- raster('/nfs/datadrivendroughteffect-data/Data/Irrigation/mirad1k_12v3_bsq/mirad1k_12v3envi.bsq')

# set projection of irrigation datasets (matches ag projection, confirmed in metadata of mirad data)

crs(y02) <- ag@crs
crs(y07) <- ag@crs
crs(y12) <- ag@crs

# NA flag

NAvalue(y02) <- min(unique(y02))
NAvalue(y07) <- min(unique(y07))
NAvalue(y12) <- min(unique(y12))

# reduce to fractional form from percent for summing

y02 <- y02/100
y07 <- y07/100
y12 <- y12/100

# mask for agricultural area applied (remove irrigated areas not flagged as agricultural)

y02 <- y02 * ag
y07 <- y07 * ag
y12 <- y12 * ag

# create ag panel

# extract_data <- function(i) {
#   extract(ag, shp_data[i,], fun=sum, na.rm=TRUE)
# }
# 
# sjob1 <- slurm_apply(extract_data, data.frame(i = seq_along(shp_data)),
#                      nodes = 10, cpus_per_node = 8,
#                      add_objects = c("ag", "shp_data"), 
#                      slurm_options = list(partition = "sesync", time='0-6:0:0')) 
# 
# result <- get_slurm_out(sjob1, "table")
# ag_area <- as.data.frame(result)
saveRDS(ag_area, '/nfs/datadrivendroughteffect-data/Data/Landuse/ag_area_by_county_sqkm.RDS')
ag_area <- readRDS('/nfs/datadrivendroughteffect-data/Data/Landuse/ag_area_by_county_sqkm.RDS')

# extract irrigation data, square km of agricultural land within a county that are irrigated

extract_data <- function(i) {
   extract(y02, shp_data[i,], fun=sum, na.rm=TRUE)
}

sjob <- slurm_apply(extract_data, data.frame(i = seq_along(shp_data)),
                     nodes = 10, cpus_per_node = 8,
                     add_objects = c("y02", "shp_data"),
                     slurm_options = list(partition = "sesync", time='0-6:0:0'))

result <- get_slurm_out(sjob, "table")
y02_area <- as.data.frame(result)
y02_perc <- y02_area/ag_area
y02_perc$V1[is.nan(y02_perc$V1)] <- 0


extract_data <- function(i) {
  extract(y07, shp_data[i,], fun=sum, na.rm=TRUE)
}

sjob <- slurm_apply(extract_data, data.frame(i = seq_along(shp_data)),
                    nodes = 10, cpus_per_node = 8,
                    add_objects = c("y07", "shp_data"),
                    slurm_options = list(partition = "sesync", time='0-6:0:0'))

result <- get_slurm_out(sjob, "table")
y07_area <- as.data.frame(result)
y07_perc <- y07_area/ag_area
y07_perc$V1[is.nan(y07_perc$V1)] <- 0


extract_data <- function(i) {
  extract(y12, shp_data[i,], fun=sum, na.rm=TRUE)
}

sjob <- slurm_apply(extract_data, data.frame(i = seq_along(shp_data)),
                    nodes = 10, cpus_per_node = 8,
                    add_objects = c("y12", "shp_data"),
                    slurm_options = list(partition = "sesync", time='0-6:0:0'))

result <- get_slurm_out(sjob, "table")
y12_area <- as.data.frame(result)
y12_perc <- y12_area/ag_area
y12_perc$V1[is.nan(y12_perc$V1)] <- 0


# merge final dataframe

irrig <- as.data.frame(cbind(y02_perc$V1, y07_perc$V1, y12_perc$V1) )
colnames(irrig) <- c("2002", "2007", "2012")
saveRDS(irrig, '/nfs/datadrivendroughteffect-data/Data/Irrigation/perc_irr_ag.RDS')





# * 250 square meters