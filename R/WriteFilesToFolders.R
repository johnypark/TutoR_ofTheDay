# get file and partition by year, put in seperate folders 
library(tidyverse)
library(lubridate)
library(magrittr)

DIR_wd=getwd()
DIR_read=paste0(DIR_wd,"/data/origin/") # set path of data location
DIR_out=paste0(DIR_wd,"/data/yearly_rainfall_BCI/")

ls_filenames<-list.files(path=DIR_read,pattern=".csv$")

df.original<-read.csv(paste0(DIR_read,ls_filenames))%>%as_tibble # use tibble for tidy data

## converting date format

date_vec<-df.original$date%>%dmy() #lubridate for easy parsing date and time
df.original$date<-date_vec
df.original%<>%mutate(year=year(date))

year_vec<-df.original$year%>%unique

for (x in year_vec){ 

df.original%>%filter(year==x)%>%write.csv(
            paste0(DIR_out,"/BCI_",x,".csv"))
}
