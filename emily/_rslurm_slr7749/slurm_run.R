.tmplib <- lapply(c('base','methods','datasets','utils','grDevices','graphics','stats','sp','rgdal','raster','stringr','gdalUtils','rgeos','dplyr','ncdf4','SDMTools','reshape2','devtools','rslurm'), 
                  library, character.only = TRUE, quietly = TRUE)
load('add_objects.RData')
.rslurm_func <- function(i) {
  extract(rast, shp_data[i,], fun=sum, na.rm=TRUE)
}

.rslurm_params <- readRDS('params.RData')
.rslurm_id <- as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID'))
.rslurm_istart <- .rslurm_id * 311 + 1
.rslurm_iend <- min((.rslurm_id + 1) * 311, nrow(.rslurm_params))
.rslurm_result <- do.call(parallel::mcMap, c(.rslurm_func,
    .rslurm_params[.rslurm_istart:.rslurm_iend, , drop = FALSE],
    mc.cores = 8))
               
saveRDS(.rslurm_result, file = paste0('results_', .rslurm_id, '.RData'))
