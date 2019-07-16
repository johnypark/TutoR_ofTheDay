library(rgdal)
path.dir<-getwd()
shp.obj1<-st_read(paste0(path.dir,"/data/BCI_50ha/BCI_50ha.shp"))
bci.50ha.extent<-readOGR("/Users/JYP/Downloads/BCI_50ha/BCI_50ha.shp")


pnts<-df_Infocrowns_bci50ha[c("PointX","PointY")] #PointX and point Y refers to stem locations
#pnts<-df_Infocrowns_bci50ha[c("Crown_Cent","Crown_Ce_1")]


pnts_sf <- do.call("st_sfc",c(lapply(1:nrow(pnts), 
                                     function(i) {st_point(as.numeric(pnts[i, ]))}), list("crs" = 32617))) 


st_intersects(shp.obj1, pnts_sf, sparse = FALSE)[1,]%>%sum() ## check if all points are within the boundary



## make a new sp object with straight polygon (after the rotation) 

library(spbabel)

df.to.sp<-function(df_object,sp_object){
  ##need to fix: if multiple objects, id and group shoud be contained
  p = Polygon(df_object[c("long","lat")])
  ps = Polygons(list(p),1)
  sps = SpatialPolygons(list(ps))
  proj4string(sps) = proj4string(sp_object)
  return(sps)}


### handle get origin long lat and get rotation matrix rot.A
shp.obj1.coord<-shp.obj1%>%st_coordinates%>%data.frame()
origin.latlong<-shp.obj1.coord[4,1:2]%>%as.matrix()
st_coordinates(shp.obj1)<-list()

df.test<-shp.obj1.coord
df.test$X<-df.test$X-origin.latlong[1]
df.test$Y<-df.test$Y-origin.latlong[2]

p1<-df.test[c("X","Y")][1,]
p3<-df.test[c("X","Y")][3,]


pt.zero<-matrix(c(0,500,1000,0),2,2)
pt.after<-matrix(c(p1%>%as.numeric,p3%>%as.numeric),2,2)
rot.A<-pt.after%*%solve(pt.zero) ##get Rotation matrix A for 
# rotating original polygon to straight polygon


ans1<-solve(rot.A)%*%(df.test[c("X","Y")]%>%as.matrix()%>%t)%>%t


df.bci.50ha.zero<-data.frame(long=c(0,1000,1000,0,0),
                             lat=c(500,500,0,0,500))

# get sp object
bci.50ha.extent.zero<-df.to.sp(df_object = df.bci.50ha.zero,sp_object = bci.50ha.extent)
# split into 1250 cells using sf
bci.50ha.extent.0.split<-st_as_sf(bci.50ha.extent.zero)%>%st_make_grid(cellsize = c(20, 20))%>%
  st_sf(grid_id = 1:length(.)) ## directly getting data from sf, don't know how to carry over 
#grid_id with the strcuture, therefore going -> sp object-> sptable -> rotate -> back to sp object
# make sp object of the split
sp.bci.50ha.extent.0.split<-bci.50ha.extent.0.split%>%as(.,"Spatial")


#=================== Way 2 : Which way is better? use of spbabel
pts.20m.grid.0<-sptable(sp.bci.50ha.extent.0.split)
pts.20m.grid.back<-data.frame((pts.20m.grid.0[c("y_","x_")]%>%as.matrix)%*%rot.A)
colnames(pts.20m.grid.back)=c("y_","x_")
pts.20m.grid.back$y_=pts.20m.grid.back$y_+origin.latlong[2]
pts.20m.grid.back$x_=pts.20m.grid.back$x_+origin.latlong[1]
pts.20m.grid.back<-pts.20m.grid.back%>%
  cbind(pts.20m.grid.0%>%select(object_,branch_,island_,order_))

sp.bci.50ha.extent.split<-sp(pts.20m.grid.back) ## sp is critical function here!!!! reversing fortify
proj4string(sp.bci.50ha.extent.split)<-proj4string(sp.bci.50ha.extent.0.split)

writeOGR(sp.bci.50ha.extent.split, dsn = '.', layer = '50ha_20by20m_grid', driver = "ESRI Shapefile")
#output: 50ha_20by20m_grid.shp
sp.bci.50ha.extent.split%>%st_as_sf()%>%plot()


## Must check: all the crown location points belong to a subsetted
## polygon



ggplot()+geom_path(data=df.bci.50ha.rot,aes(long,lat))+
  geom_path(data=fortify(sp.bci.50ha.extent.rot.split),aes(long,lat,group=group,color=group))+
  theme(legend.position = "none")


ggplot()+
  geom_path(data=pts.20m.grid.back,aes(x_,y_,group=object_),color='gray')+
  theme(legend.position = "none")+
  geom_path(data=df.bci.50ha.polygon,aes(long,lat))+theme_classic()+
  geom_path(data = poly_1, 
            aes(x = long, y = lat,group=group),
            size = .2)+
  geom_point(data=df_Infocrowns_bci50ha,aes(PointX,PointY),color="blue",alpha=0.3)+
  geom_point(data=df_Infocrowns_bci50ha,aes(Crown_Cent,Crown_Ce_1),color="red",alpha=0.15)+
  
  geom_path(data=fortify(bci.50ha.extent),aes(long,lat),color="red")+xlab("utm_x")+ylab("utm_y")


### merge dataset

df.bci.soil<-read.csv("/Users/JYP/Documents/Phenology2_Diversity/DATA/bci.block20.data-1.csv")
colnames(df.bci.soil)[1]<-"x"
df.bci.soil<-df.bci.soil%>%arrange(y)
df.bci.soil$rownumber_<-c(1:1250)

df.bci.soil%>%ggplot(aes(x,y,color=rownumber_))+geom_point()+theme_classic()

bci.50ha.SoilMap<-sp.bci.50ha.extent.split%>%st_as_sf()%>%left_join(df.bci.soil,by="rownumber_")

