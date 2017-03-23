library(raster)
library(rslurm)
library(stringr)

# globals
crops <- list("ag", "eco", "maize", "wheat", "soy") 
#vars <- list("tmean", "precip", "Zdeficit", "deficit")
res <- "365" #"weekly"
dname <- 'PRISM' #NARR", "NLDAS", 
dlist <- Sys.glob(paste('/nfs/datadrivendroughteffect-data/Data/PRISM/PRISM_daily_ppt','_', '*','.nc', sep = ''))
outfn <- '/nfs/datadrivendroughteffect-data/Data/Masked_data/PRISM_annual_ppt'

matrix_prep <- function(dname, dlist, res, crops) {

    for (i in 1:length(crops)) {
      
      mask <- brick(paste('/nfs/datadrivendroughteffect-data/Data/Masks/final_masks/', dname, '_', res, 
                          '_', crops[i], '_frac.nc', sep=''))
      d <- stack()
      d2 <- stack()
      d3 <- stack()
      dnames <- list()
      
      for (y in 1:length(dlist)) {
        
        #extract layer name information
        lname <- str_sub(dlist[y],-7,-4)
        
        #polynomial transformation
        year <- brick(dlist[y])
        year2 <- year*year
        year3 <- year*year*year
        print(paste('Polynomial transformations complete for',dlist[y]))
        
        #apply fractional mask
        myear <- year*mask
        myear2 <- year2*mask
        myear3 <- year3*mask
        print(paste('Masking complete for',dlist[y]))
    
        #per pixel average through time
        avg <- calc(myear, fun=mean, na.rm=T)
        avg2 <- calc(myear2, fun=mean, na.rm=T)
        avg3 <- calc(myear3, fun=mean, na.rm=T)
        print(paste('Averaging complete for',dlist[y]))
        
        #append stack
        d <- stack(d, avg)
        d2 <- stack(d2, avg)
        d3 <- stack(d3, avg)
        dnames <- append(dnames, lname)

      }
    
      names(d) <- dnames
      names(d2) <- dnames
      names(d3) <- dnames
      writeRaster(d, paste(outfn,'_',crops[i],'.grd',sep=''), format='raster') 
      print(paste('Saving:', paste(outfn,'_',crops[i],'.grd',sep='')))
      writeRaster(d2, paste(outfn,'_',crops[i],'_','squared.grd',sep=''), format='raster')
      print(paste('Saving:', paste(outfn,'_',crops[i],'_','squared.grd',sep='')))
      writeRaster(d3, paste(outfn,'_',crops[i],'_', 'cubed.grd',sep=''), format='raster')
      print(paste('Saving:', paste(outfn,'_',crops[i],'_','cubed.grd',sep='')))
      
  
  } 
}

matrix_prep(dname="PRISM",dlist=dlist,res="365",crops=crops)

#How to send maize, wheat, soy, ag, eco to separate nodes?
#Possible to parallelize BOTH crop data preparation (1:length(crops) and annual dataset preparation (1:length(dlist)))
sjob <- slurm_apply(matrix_prep, data.frame(crops = crops[i]),
                    nodes = 10, cpus_per_node = 8,
                    add_objects = c("dname", "dlist", "res", "crops"), 
                    slurm_options = list(partition = "sesync"))


sjob <- slurm_apply(function(i) func(obj_list[[i]]), 
                    data.frame(i = seq_along(obj_list)),
                    add_objects = c("func", "obj_list"),
                    nodes = 2, cpus_per_node = 2)