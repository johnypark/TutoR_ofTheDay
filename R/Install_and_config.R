## install and config 
Sys.setenv(GDAL_DATA="/Library/Frameworks/GDAL.framework/Versions/2.2/Resources/gdal")

arg.config1=c(
  '--with-gdal-config=/Library/Frameworks/GDAL.framework/Programs/gdal-config',
  '--with-proj-include=/Library/Frameworks/PROJ.framework/Headers',
  '--with-proj-lib=/Library/Frameworks/PROJ.framework/unix/lib',
  '--with-proj-share=/Library/Frameworks/PROJ.framework/unix/share/proj')
install.packages('sf', type = "source", configure.args=arg.config1)

install.packages("~/Desktop/sf_0.6-1.tar.gz", repos = NULL, type = "source", configure.args=arg.config1)