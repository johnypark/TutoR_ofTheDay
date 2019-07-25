library(tidyverse)
library(RCzechia)
library(sf)

#test

#https://www.r-spatial.org/r/2018/10/25/ggplot2-sf.html
mesto <- kraje() %>% # All Czech NUTS3 ...
  filter(KOD_KRAJ == '3018') %>% # ... city of Prague
  st_transform(5514) # a metric CRS 

krabicka <- st_bbox(mesto)
xrange <- krabicka$xmax - krabicka$xmin
yrange <- krabicka$ymax - krabicka$ymin

grid_spacing <- 1000  # size of squares, in units of the CRS (i.e. meters for 5514)

rozmery <- c(xrange/grid_spacing , yrange/grid_spacing) %>% # number of polygons necessary
  ceiling() # rounded up to nearest integer

polygony <- st_make_grid(mesto, square = T, n = rozmery) %>% # the grid, covering bounding box
  st_intersection(mesto) %>% # only the inside part 
  st_sf() # not really required, but makes the grid nicer to work with later

plot(polygony, col = 'white')

rotang = 20
rot = function(a) matrix(c(cos(a), sin(a), -sin(a), cos(a)), 2, 2)
grd<-polygony
grd_rot <- (grd - st_centroid(st_union(grd))) * rot(rotang * pi / 180) +
  st_centroid(st_union(grd))
st_crs(grd_rot)=5514

grd_rot<-grd_rot%>%st_intersection(mesto)%>%st_sf
plot(inpoly, col = "blue")
plot(grd_rot, add = TRUE)

library("rnaturalearth")
library("rnaturalearthdata")

world <- ne_countries(scale = "medium", returnclass = "sf")
class(world)

ggplot(data = world) +
  geom_sf() +
  coord_sf(crs = "+proj=laea +lat_0=52 +lon_0=10 +x_0=4321000 +y_0=3210000 +ellps=GRS80 +units=m +no_defs ")


ggplot(data = world) +
  geom_sf() +
  coord_sf(xlim = c(-102.15, -74.12), ylim = c(7.65, 33.97), expand = FALSE)



library("ggspatial")
ggplot(data = world) +
  geom_sf() +
  annotation_scale(location = "bl", width_hint = 0.5) +
  annotation_north_arrow(location = "bl", which_north = "true", 
                         pad_x = unit(0.75, "in"), pad_y = unit(0.5, "in"),
                         style = north_arrow_fancy_orienteering) +
  coord_sf(xlim = c(-102.15, -74.12), ylim = c(7.65, 33.97))
