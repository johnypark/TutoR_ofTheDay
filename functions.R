##functions

df.to.sp<-function(df_object,sp_object){
  ##need to fix: if multiple objects, id and group shoud be contained
  p = Polygon(df_object[c("long","lat")])
  ps = Polygons(list(p),1)
  sps = SpatialPolygons(list(ps))
  proj4string(sps) = proj4string(sp_object)
  return(sps)}