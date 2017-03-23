library(raster)
library(rgeos)
library(rslurm)

lulc <- raster("/nfs/datadrivendroughteffect-data/Data/Masks/lulc_mode.grd")
data_prism <- brick("/nfs/datadrivendroughteffect-data/Data/PRISM/PRISM_daily_ppt_1981.nc")

# Polygonize all the non-NA (i.e. land) PRISM cells and project to lulc CRS
prism_poly <- rasterToPolygons(data_prism[[1]], na.rm = TRUE)
prism_poly <- spTransform(as(prism_poly, "SpatialPolygons"), projection(lulc))

# Define helper functions
prop_maize <- function(x, na.rm) {
    mean(x %in% c(22, 23), na.rm = na.rm)
}

extract_maize <- function(i) {
    extract(lulc, prism_poly[i], fun = prop_maize, na.rm = TRUE)
}

# Run extraction on cluster (projected run time: ~90 min for all data_prism)
sjob <- slurm_apply(extract_maize, data.frame(i = seq_along(prism_poly)),
                    nodes = 12, cpus_per_node = 8, 
                    add_objects = c("lulc", "prism_poly", "prop_maize"),
                    slurm_options = list(partition = "sesync"))

#print_job_status(sjob)  

res <- get_slurm_out(sjob, outtype = "table")
cleanup_files(sjob)

# Remove some polygons outside raster area (extract is NULL)
null_res <- which(sapply(res$V1, is.null))
prism_poly <- prism_poly[-null_res]

# Put extracted results into SpatialPolygonsDataFrame,
#  reproject to longlat and rasterize (based on polygon centroids)
prism_poly <- SpatialPolygonsDataFrame(prism_poly, 
                                       data.frame(maize = unlist(res$V1)),
                                       match.ID = FALSE)
prism_poly <- spTransform(prism_poly, projection(data_prism))
prism_points <- SpatialPointsDataFrame(gCentroid(prism_poly, byid = TRUE), 
                                       prism_poly@data, match.ID = FALSE)
maize_raster <- rasterize(prism_points, data_prism[[1]], field = "maize", 
                          filename = "wheat_raster.grd")


