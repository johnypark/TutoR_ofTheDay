## read multiple files from folder

DIR_wd=getwd()
DIR_path=paste0(DIR_wd,"/data/yearly_rainfall_BCI/") # set path of data location


ls_filenames<-list.files(path=DIR_path,pattern=".csv$")

df.current<-list()
for (i in 1:length(ls_filenames)){
df.current[[i]]<-read.csv(paste0(DIR_path,ls_filenames[i]))
}

names(df.current)=ls_filenames # assign name for each list element: corresponding file names


