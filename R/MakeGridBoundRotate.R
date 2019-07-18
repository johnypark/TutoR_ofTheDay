#Make grid and bound it with polygon

#https://stackoverflow.com/questions/53789313/creating-an-equal-distance-spatial-grid-in-r

#with rotation
#https://stackoverflow.com/questions/51282724/creating-a-regular-polygon-grid-over-a-spatial-extent-rotated-by-a-given-angle

library(tidyverse)
library(RCzechia)
library(sf)


mesto <- kraje() %>% # All Czech NUTS3 ...
  filter(KOD_CZNUTS3 == "CZ010" ) %>% # ... city of Prague
  st_transform(5514) # a metric CRS 

krabicka <- st_bbox(mesto)

xrange <- krabicka[3] - krabicka[1]
yrange <- krabicka[4] - krabicka[2]

grid_spacing <- 1000  # size of squares, in units of the CRS (i.e. meters for 5514)

rozmery <- c(xrange/grid_spacing , yrange/grid_spacing) %>% # number of polygons necessary
  ceiling() # rounded up to nearest integer

polygony <- st_make_grid(mesto,n=rozmery)%>%st_sf(id_grid=c(1:length(.)))#, #square = T, n = rozmery) %>% # the grid, covering bounding box
  st_join(mesto) %>% # only the inside part 
  st_sf() # not really required, but makes the grid nicer to work with later

rotang = 20
rot = function(a) matrix(c(cos(a), sin(a), -sin(a), cos(a)), 2, 2)
grd_rot <- (polygony - st_centroid(st_union(polygony))) * rot(rotang * pi / 180) +
  st_centroid(st_union(polygony))


plot(polygony, col = 'white')