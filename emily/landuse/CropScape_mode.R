# Load data
cs_list <- Sys.glob(paste("/nfs/datadrivendroughteffect-data/Data/Landuse/CropScape/","*","_30m_cdls.img",sep=""))
lulc_stk <- stack(raster(cs_list[1]), raster(cs_list[2]), raster(cs_list[3]), raster(cs_list[4]),
                  raster(cs_list[5]), raster(cs_list[6]), raster(cs_list[7]))

# Calculate mode for section i of raster, where each section has row_chunk rows
calc_part <- function(i) {
    # Output directory for raster parts must be already there
    outdir <- "/nfs/datadrivendroughteffect-data/data_driven_drought/lulc_mode"
    row_chunk <- 1006 # chosen to get 96 chunks
    row_min <- (i - 1) * row_chunk + 1
    row_max <- min(i * row_chunk, nrow(lulc_stk))
    # Crop raster for selected rows and all columns
    lulc_crop <- crop(lulc_stk, extent(lulc_stk, 
                                        row_min, row_max, 1, ncol(lulc_stk)))
    calc(lulc_crop, fun = modal, na.rm = TRUE, datatype = "INT1U",
         filename = paste0(outdir, "/out", i, ".grd"))
}

# Parallelize over cluster
sjob <- slurm_apply(calc_part, params = data.frame(i = 1:96), nodes = 12,
                    cpus_per_node = 8, add_objects = "lulc_stk",
                    slurm_options = list(partition = "sesync"))

# Get output from cluster (as list of RasterLayer objects)
out_rasters <- get_slurm_out(sjob)

# This is equivalent to:
#  merge(out_rasters[[1]], out_rasters[[2]], ..., out_rasters[[96]],
#        datatype = "INT1U", filename = "merged_mode.grd")
merged_raster <- do.call(merge, c(out_rasters, datatype = "INT1U", 
                                  filename = "merged_mode.grd"))
