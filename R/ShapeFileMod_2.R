## John Park Jul 15 2019 organizing the code. 
library(sf)
library(sp)
library(rgdal)
library(spbabel)
library(dplyr)
################ functions #########################
GetMatrixFromSf<-function(sfextent){
  if(class(sfextent)[1]!="sf"){
  stop("input must be of class sf")}
### handle get origin long lat and get rotation matrix rot.A
  sfextent.coord<-sfextent%>%st_coordinates%>%data.frame() ## extract coordinates of the polygon 
  origin<-sfextent.coord[sfextent.coord$X==min(sfextent.coord$X),][1:2]%>%
    as.matrix
## get coordinates of origin
  dft<-sfextent.coord
  dft$X<-dft$X-origin[1] # get long(x) values after setting origin
  dft$Y<-dft$Y-origin[2] # get lat(y) values after setting origin 
  c1<-dft[c("X","Y")][1,] ## extract point for (x,0) after transpose  
  c3<-dft[c("X","Y")][3,] ## extract point for (0,y) after transpose
  mA<-matrix(c(c1%>%as.numeric,c3%>%as.numeric),2,2)
  
  ans1<-solve(mA)%*%(dft[c("X","Y")]%>%as.matrix()%>%t)%>%t ## check if this works
  
return(list(matrix=mA,
            origin.latlong=origin,
            check=ans1
            ))
}

GetTransMatrix<-function(matrix_C_orig, matrix_C_trans){
  rot.A<-matrix_C_trans%*%solve(matrix_C_orig)
return(rot.A) ## get transpose matrix A from A*C=C', A=C'*inv(C)
}
## transferring coordinates with transition matrix A, origin latong
TransCoordinates<-function(InputSptable,TransMatrixA,orig_latlong){
  input_crds<-InputSptable
  trns_A<-TransMatrixA
  Olatlong<-orig_latlong
  res_trans<-data.frame((input_crds[c("y_","x_")]%>%
                           as.matrix)%*%trns_A)
  colnames(res_trans)=c("y_","x_")
  res_trans$y_=res_trans$y_+Olatlong[2]
  res_trans$x_=res_trans$x_+Olatlong[1]
  res_trans<-res_trans%>%
    cbind(input_crds%>%select(object_,branch_,island_,order_))
  return(res_trans)
}
### Make grid and transform
MakeGridTrans<-function(SfObjectRect,SfOrigRect,CellSize){
  shp.obj1<-SfObjectRect
  
  bci.50ha.extent<-as(shp.obj1,"Spatial") ## sp object for the same data
  res<-GetMatrixFromSf(shp.obj1)
  C_after<-res$matrix
  C_zero<-matrix(c(0,500,1000,0),2,2)
  rot.A<-GetTransMatrix(C_zero,C_after) # get rotation matrix A
  origin.latlong<-res$origin.latlong # get lat long origin
  
  # split into 1250 cells using sf::st_make_grid() function
  Bci50ha_orig_grid<-Bci50haExtent_orig%>%
    st_make_grid(cellsize = c(CellSize, CellSize))%>%
    st_sf(grid_id = 1:length(.))
  
  ## sf-> spbabel::sptable to get all coordinates with detiled object info  
  ## sptable make things much easier. 
  
  GridCrds_20m_orig<-sptable(Bci50ha_orig_grid) ##spbabel::sptable 
  #"The long-form single table of all coordinates, with object, branch, island-status, and order provides a reasonable middle-ground for transferring between different representations of Spatial data. "
  
  GridCrds_20m_trans<-TransCoordinates(GridCrds_20m_orig,
                                       TransMatrixA = rot.A, #rotate orig points with rot. A
                                       orig_latlong = origin.latlong) #put back original lat long 
  
  sp_BCI50ha_grid<-sp(GridCrds_20m_trans,
                      crs=proj4string(bci.50ha.extent)) # function spbabel::sf does not work currently, 
  
  return(st_as_sf(sp_BCI50ha_grid))
}#so convert sp first and change sp to sf. 


################## __MAIN__ ################################

path.dir<-getwd()
sf_bci50ha<-st_read(paste0(path.dir,"/data/BCI_50ha/BCI_50ha.shp")) ##sf object 

df_bci50ha_orig<-data.frame(long=c(0,1000,1000,0,0),
                            lat=c(500,500,0,0,500)) 
# make sf object with coordinates with sf::st_polygon, sf:st_sfc. 
Bci50haExtent_orig<-df_bci50ha_orig%>%as.matrix%>%list%>% #is sf object now
  st_polygon()%>%st_sfc(.,crs=st_crs(sf_bci50ha))%>%st_sf()

BCI50ha_grid<-MakeGridTrans(SfObjectRect = sf_bci50ha,
                              SfOrigRect = Bci50haExtent_orig,
                              CellSize = 20)
plot(BCI50ha_grid)

writeOGR(BCI50ha_grid%>%as(.,"Spatial"), dsn = '.', layer = '50ha_20by20m_grid', driver = "ESRI Shapefile")
#output: 50ha_20by20m_grid.shp

## Must check: all the crown location points belong to a subsetted
## polygon
#df%>%filter(.data[["L1"]]==one) #rlang 0.4.0 should work
 

