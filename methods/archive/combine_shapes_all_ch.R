setwd("~/Digital-Forest-Monitoring/methods")

library(raster)
library(rgdal)
library(doParallel)

path = "/mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case2/Test_all/"

polys.files = list.files(path, pattern=".shp", recursive = T, full.names = T)
polys.files = grep("nbr_change_T", polys.files, value=T)

cl = makeForkCluster(detectCores() -1)
registerDoParallel(cl)

all_change = foreach(i=2:8, .packages = c("raster", "rgdal"), .combine = "rbind") %dopar% {

  polys = shapefile(polys.files[i])
  polys$p90 = round(as.numeric(polys$p90))
  polys$mean = round(as.numeric(polys$mean))
  polys$max = as.numeric(polys$max)
  polys$area = as.numeric(polys$area)
  return(polys)
  #vec = unique(polys$time)
  #assign(paste("t",i,sep=""), vec, envir = .GlobalEnv)
}

stopCluster(cl)

all_change = spTransform(all_change, CRS("+init=epsg:3857"))

polys_t31 = shapefile(polys.files[1])
#assign(paste("t",i,sep=""), unique(polys_t31$time), envir = .GlobalEnv)
polys_t31 = spTransform(polys_t31, CRS("+init=epsg:3857"))

all_change = rbind(all_change, polys_t31)
shp = file.path(path, paste("2017_nbr_change_all_epsg3857.shp", sep=""))
shapefile(all_change, shp, overwrite = T)

#arr = as.array(table(t))
#plot(arr, xaxt="n",yaxt="n",ylab="frequency",xlab="")
#axis(2,at=0:8, labels=0:8)
#axis(1,at = 1: 15, labels=sort(unique(t)),las=2)
