####################################
#EXAMPLE ONLY - WILL NOT RUN - MISSING DATA FILES (too big for github)
####################################

library(rgl)
library(anglr) #install this with devtools::install_github("hypertidy/anglr")
library(raster)

tas_DEM <- readAll(raster("~/Documents/Data/tasDEM_2015.tif"))
tas_DEM
plot(tas_DEM)

TWWHA <- shapefile("~/Documents/Data/TasmaniaWorldHertiageArea/Wha_region.shp")
TWWHA
#tas_DEM and TWWHA have the same projection (+proj=utm +zone=55 +south +ellps=GRS80 +units=m +no_defs) 
#so I am not checking that first. See elsewhere on help transforming and matching projections...
plot(TWWHA, add=TRUE, lwd=0.3)

#convert shape into a 3D mesh
TWWHA_meshed <- anglr(TWWHA)
TWWHA_meshed
plot(TWWHA_meshed)

#add z dimension (elevation) to the mesh
TWWHA_meshed$v$z_ <- extract(tas_DEM, as.matrix(TWWHA_meshed$v[, c("x_", "y_")]))
rgl.clear()
plot(TWWHA_meshed)
#rgl needs me to define the proportions of each dimension - elevation needs to be downscaled.
rgl::aspect3d(1, 1, 0.05)

#Its ugly because of big triangles lets make them smaller
TWWHA_meshed_small_tris <- anglr(TWWHA, max_area=1e6) #1e6 is total area in metres
TWWHA_meshed_small_tris$v$z_ <- extract(tas_DEM, as.matrix(TWWHA_meshed_small_tris$v[, c("x_", "y_")]), method="bilinear" )
rgl.clear()
plot(TWWHA_meshed_small_tris); rgl::aspect3d(1, 1, 0.05)

