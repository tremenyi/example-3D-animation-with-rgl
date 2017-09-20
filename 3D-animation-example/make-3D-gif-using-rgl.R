#requires imagemagic and netcdf to be installed on the system
library(raster)
library(rgl)
library(quadmesh)
library(viridis)

#define functions

#function that changes the surface colour used by a layer based on data from another source
change_surface_colour <- function(target_orog, target_var, target_timestep, target_colour_palette){
  rescaled_var <- scales::rescale(values(target_var[[target_timestep]]), c(1,length(target_colour_palette) ) )
  reped_rescaled_var <- rep(rescaled_var, each=4)
  target_orog$material$col <- target_colour_palette[reped_rescaled_var]
  return(target_orog)
} #close function change_surface_colour

#function that changes the transparency of layer base on data from another source
create_shade3d_layer <- function(target_brick, target_timestep, target_height){
  br_i <- target_brick[[target_timestep]]
  br_i_alpha_vals <- values(br_i)
  br_i_alpha_vals[is.na(br_i_alpha_vals)] <- 0
  br_qm <- quadmesh(br_i)
  if(length(target_height) == 1){
    br_qm$vb[3,] <- target_height
  } else {
    br_qm$vb <- target_height
  }
  br_qm$material$alpha <- rep(br_i_alpha_vals, each=4) #because its a quadmesh, its 4
  return(br_qm)
} #close function create_shade3d_layer

parent_directory <- "/Users/tremenyi/Documents/DaSH/Plotting_in_R/3D-animation-example"
#load data
orog <- raster(sprintf("%s/data/orog.nc", parent_directory)) #2D variable - lon, lat; orog = orography (i.e. surface elevation)
tas <- brick(sprintf("%s/data/tas.nc", parent_directory)) #3D variable - lon, lat, time; tas = surface temperature
cll <- brick(sprintf("%s/data/cll.nc", parent_directory)) #4D variable - lon, lat, elevation, time; cll = percentage cover of 'low' cloud
clm <- brick(sprintf("%s/data/clm.nc", parent_directory))
clh <- brick(sprintf("%s/data/clh.nc", parent_directory)) #4D variable - lon, lat, elevation, time; clh = percentage cover of 'high' cloud

#rescale cloud layers so they can be used as transparency (alpha) values, I have selected 0.9 as the top so that full cloud is still a bit see through in the animation.
values(cll) <- scales::rescale(values(cll), to = c(0,0.9))
values(clm) <- scales::rescale(values(clm), to = c(0,0.9))
values(clh) <- scales::rescale(values(clh), to = c(0,0.9))

#create topography layer / surface
orog_qm <- quadmesh(orog)

#until I figure out how to get this from the data in th emodel, allow the clouds to move over the land (rather than through it!)
##smooth out orography to simulate an atmospheric layer
orog_smooth <- focal(orog, w=matrix(1, 5, 5), mean)
##use the smooth orography to simulate influence of the topography on the cloud heights.
orog_qm_cll <- quadmesh((orog_smooth/4)+1000)
orog_qm_clm <- quadmesh((orog_smooth/6)+2000)
orog_qm_clh <- quadmesh((orog_smooth/8)+4000)

#tas_colours <- colorRampPalette(c("dodgerblue", "purple", "firebrick"))(100)
tas_colours <- viridis(100)

create_pngs_time_start <- Sys.time()

#set the size of the window. Keep it square unless the data is not square-ish if your going to rotate the view.  
rgl.clear()
rgl.close()
r3dDefaults$windowRect <- c(0,0, 600, 600) 

#timestep <- 1
for(timestep in 1:nlayers(tas) ){
  tmp_file_name <- sprintf("%s/Frames_for_animation/frame_for_animation_%04d.png", parent_directory, timestep)
  par3d(windowRect = c(0,0, 600, 600))
  shade3d(change_surface_colour(target_orog = orog_qm, target_var = tas, target_timestep = timestep, target_colour_palette = tas_colours ), smooth=F)
  bg3d("dodgerblue")
  aspect3d(1,1,0.15)
  shade3d(create_shade3d_layer(target_brick = clh, target_timestep = timestep, target_height = orog_qm_clh$vb), col="white")
  #shade3d(create_shade3d_layer(target_brick = clm, target_timestep = timestep, target_height = orog_qm_clm$vb), col="white")
  shade3d(create_shade3d_layer(target_brick = cll, target_timestep = timestep, target_height = orog_qm_cll$vb), col="white")
  if(timestep < 2){
    rgl.viewpoint(theta = 0, phi = -70)
    starting_viewpoint <- par3d("userMatrix")
    rotated_viewpoints <- vector("list", length=360)
    rotation_ind <- 0
    for(tmp_theta in seq(0, 2*pi, len=360)) { 
      rotation_ind <- rotation_ind + 1
      rotated_viewpoints[[rotation_ind]] <- rotate3d(starting_viewpoint, tmp_theta, 0,0,1) # Rotate about model's z axis 
    }#close for tmp_theta
    rgl.viewpoint(userMatrix = rotated_viewpoints[[ c(timestep %% 359)+1 ]])
    snapshot3d(filename = tmp_file_name)
  } else {
    rgl.viewpoint(userMatrix = rotated_viewpoints[[ c(timestep %% 359)+1 ]])
    snapshot3d(filename = tmp_file_name)
  } #close if timestep < 2
  rgl.clear()
}#close for timestep
create_pngs_time_end <- Sys.time()

print(create_pngs_time_end-create_pngs_time_start)

#use imagemagick at the command line to stich the images together
system(command = sprintf("convert -delay 10 -loop 0 %s/Frames_for_animation/frame_for_animation*.png %s/3D-animation.gif", parent_directory, parent_directory) )

