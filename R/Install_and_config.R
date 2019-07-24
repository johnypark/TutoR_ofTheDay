## install and config sf package

## https://stackoverflow.com/questions/43597632/understanding-the-contents-of-the-makevars-file-in-r-macros-variables-r-ma
## https://github.com/r-spatial/sf/issues/1105?email_source=notifications&email_token=AEFV3VAX3ILCPD4K6HF6Q3TP75WRBA5CNFSM4IEDKDWKYY3PNVWWK3TUL52HS4DFVREXG43VMVBW63LNMVXHJKTDN5WW2ZLOORPWSZGOD2GKFVY#issuecomment-512533207
Sys.setenv(GDAL_DATA="/Library/Frameworks/GDAL.framework/Versions/2.2/Resources/gdal")

arg.config1=c(
  '--with-gdal-config=/Library/Frameworks/GDAL.framework/Programs/gdal-config',
  '--with-proj-include=/Library/Frameworks/PROJ.framework/Headers',
  '--with-proj-lib=/Library/Frameworks/PROJ.framework/unix/lib',
  '--with-proj-share=/Library/Frameworks/PROJ.framework/unix/share/proj')
install.packages('sf', type = "source", configure.args=arg.config1)

install.packages("lwgeom",type = "source", configure.args=arg.config1)

install.packages("~/Desktop/sf_0.5-5.tar.gz", repos = NULL, type = "source",
                 configure.args=arg.config1)

#install.packages("~/Desktop/sf_0.6-1.tar.gz", repos = NULL, type = "source", configure.args=arg.config1)