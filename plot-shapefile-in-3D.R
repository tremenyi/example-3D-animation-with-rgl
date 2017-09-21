library(anglr) #install this with devtools::install_github("hypertidy/anglr")
library(raster)

TWWHA <- shapefile("~/Documents/Data/TasmaniaWorldHertiageArea/Wha_region.shp")
TWWHA
plot(TWWHA)

TWWHA_meshed <- anglr(TWWHA)
TWWHA_meshed
plot(TWWHA_meshed)

tas_DEM <- readAll(raster("~/Documents/Data/tasDEM_2015.tif"))
tas_DEM
plot(tas_DEM)

#these have the same projection (+proj=utm +zone=55 +south +ellps=GRS80 +units=m +no_defs) so I am not checking that first...

TWWHA_meshed$v$z_ <- extract(tas_DEM, as.matrix(TWWHA_meshed$v[, c("x_", "y_")]))
rgl::aspect3d(1, 1, 0.1)
#ugly because of big triangles
#
TWWHA_meshed_small_tris <- anglr(TWWHA, max_area=1e6) #1e6 is total area in metres
TWWHA_meshed_small_tris$v$z_ <- extract(tas_DEM, as.matrix(TWWHA_meshed_small_tris$v[, c("x_", "y_")]), method="bilinear" )
plot(TWWHA_meshed_small_tris); 
rgl::aspect3d(1, 1, 0.05)

