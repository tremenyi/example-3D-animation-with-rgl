#create animations of climate futures data
library(ggplot2)
library(gganimate)
#library(ggplotly)
library(tidync)

tas <- tidync("/rdsi/private/climatefutures/ACCESS1-0/tas10km/tas_1hr_ccam_wine_access1-0_tas10km.2000-2009.nc") %>%
  hyper_filter(time = index < 366) %>%
  hyper_tibble()
clh <- tidync("/rdsi/private/climatefutures/ACCESS1-0/tas10km/clh_1hr_ccam_wine_access1-0_tas10km.2000-2009.nc") %>%
  hyper_filter(time = index < 366) %>%
  hyper_tibble()
clm <- tidync("/rdsi/private/climatefutures/ACCESS1-0/tas10km/clm_1hr_ccam_wine_access1-0_tas10km.2000-2009.nc") %>%
  hyper_filter(time = index < 366) %>%
  hyper_tibble()
cll <- tidync("/rdsi/private/climatefutures/ACCESS1-0/tas10km/cll_1hr_ccam_wine_access1-0_tas10km.2000-2009.nc") %>%
  hyper_filter(time = index < 366) %>%
  hyper_tibble()

#Aus <- raster::getData("GADM_2.8_AUS_adm0.rds", level=0)

plotted_layers <- ggplot(data=tas, aes(lon, lat, frame=time, fill=tas)) + 
  theme_void() + 
  geom_raster(interpolate = TRUE) +
  scale_fill_gradientn(
    name="Surface\nTemperature", 
    colours = rev(c("firebrick", "red", "orange", "yellow", "green", "dodgerblue2", "dodgerblue3", "dodgerblue4")),
    breaks = seq(273,323, length=6), 
    labels = c(0, 10, 20, 30, 40, 50), 
    limits = c(270, 310)
  ) +
  geom_raster(data=cll, aes(lon, lat, alpha=cll/100, fill=NULL), fill="grey90", interpolate = TRUE) + 
  geom_raster(data=clm, aes(lon, lat, alpha=clm/100, fill=NULL), fill="grey95", interpolate = TRUE) +
  geom_raster(data=clh, aes(alpha = clh/100), fill="white", interpolate = TRUE) +
  scale_alpha_continuous(guide=FALSE, limits=c(0,1))

gganimate(
  plotted_layers, 
  "/mnt/WineAustralia_working_files/animations/ANIMATION-tas10km-1hrly-surface-temperature-with-cloud-at-lmh.gif", 
  interval = 0.23
  )


