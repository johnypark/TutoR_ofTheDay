R basics: Reading from multiple file names
================
tutoR\_ofTheDay
July 3, 2019

### Examples using rainfall data from Barro Colorado Island

We will explore dealing with loading and using datasets in mulitple occasions. In today's tutorial, we will explore how to read files by files and to make it easier to access each file's information with labels.

First, the data we will be using is a time series of daily rainfall data collected at the clearing (‘El Claro’), the original meteorological station maintained by STRI. See <https://biogeodb.stri.si.edu/physical_monitoring/research/barrocolorado>

List of the functions we will be using today are R basic functions (which means we don't need to load any packages):

`base::getwd` `base::paste0` `base::list.files` `base::list` `utils::read.csv` `base::names`

We start off with setting working directory and path for reading files.

``` r
DIR_wd=getwd() #get working directory
DIR_path=paste0(DIR_wd,"/data/yearly_rainfall_BCI/") #set path of data location
```

``` r
ls_filenames<-list.files(path=DIR_path,pattern='.csv$')
```

Function base::list.files() returns vectors of names of files and / or directoties in the designated path. Note that I used an argument `pattern=".csv$"` in this case, to only retrieve file names ending with ".csv".

Please note that character`$` is "regular expression". What are regular expressions? In my terms, they are set of grammers to define search patterns. For example, character `$` is one of the regular expression syntax incidating the end of the string. R doesn't have very strick standard in using search patterns, since we would need an extra character `\` (escape) to declare that we are using the following character`.` as a literal. (therefore `pattern="\\.csv$"` is correct term here. Note that you need to escape one more time in R!) For more details in regular expressions, please refer to other sources such as \[link\].

Now, let us see what `ls_filenames` object contains:

``` r
print(ls_filenames)
```

    ##  [1] "BCI_1971.csv" "BCI_1972.csv" "BCI_1973.csv" "BCI_1974.csv"
    ##  [5] "BCI_1975.csv" "BCI_1976.csv" "BCI_1977.csv" "BCI_1978.csv"
    ##  [9] "BCI_1979.csv" "BCI_1980.csv" "BCI_1981.csv" "BCI_1982.csv"
    ## [13] "BCI_1983.csv" "BCI_1984.csv" "BCI_1985.csv" "BCI_1986.csv"
    ## [17] "BCI_1987.csv" "BCI_1988.csv" "BCI_1989.csv" "BCI_1990.csv"
    ## [21] "BCI_1991.csv" "BCI_1992.csv" "BCI_1993.csv" "BCI_1994.csv"
    ## [25] "BCI_1995.csv" "BCI_1996.csv" "BCI_1997.csv" "BCI_1998.csv"
    ## [29] "BCI_1999.csv" "BCI_2000.csv" "BCI_2001.csv" "BCI_2002.csv"
    ## [33] "BCI_2003.csv" "BCI_2004.csv" "BCI_2005.csv" "BCI_2006.csv"
    ## [37] "BCI_2007.csv" "BCI_2008.csv" "BCI_2009.csv" "BCI_2010.csv"
    ## [41] "BCI_2011.csv" "BCI_2012.csv" "BCI_2013.csv" "BCI_2014.csv"
    ## [45] "BCI_2015.csv" "BCI_2016.csv" "BCI_2017.csv" "BCI_2018.csv"
    ## [49] "BCI_2019.csv"

Perfect! we see all the filenames are listed in `ls_filenames` object.

Next, we read files using for loop control, and assign each objects to `list` elements. `list` is particularly easy and useful for this purpose, but there could be mulitple other ways to do this operation. I chose `list` because it is more flexible with assigning different datasets to a single object.

``` r
df.current<-list()
for (i in 1:length(ls_filenames)){
df.current[[i]]<-read.csv(paste0(DIR_path,ls_filenames[i]))
}
```

Now, we check if we have the dataset we want.

``` r
ls_filenames[1]
```

    ## [1] "BCI_1971.csv"

``` r
head(df.current[[1]])
```

    ##   X     datetime       date   ra1 ra2   raw    ra comment chk_note
    ## 1 1  7/4/71 8:55 1971-04-07 2.286   0 2.286 2.286      NA     good
    ## 2 2  8/4/71 8:55 1971-04-08 0.000   0 0.000 0.000      NA     good
    ## 3 3  9/4/71 8:55 1971-04-09 0.000   0 0.000 0.000      NA     good
    ## 4 4 10/4/71 8:55 1971-04-10 0.000   0 0.000 0.000      NA     good
    ## 5 5 11/4/71 8:55 1971-04-11 0.000   0 0.000 0.000      NA     good
    ## 6 6 12/4/71 8:55 1971-04-12 1.016   0 1.016 1.016      NA     good
    ##   chk_fail year
    ## 1          1971
    ## 2          1971
    ## 3          1971
    ## 4          1971
    ## 5          1971
    ## 6          1971

Great! first element of list contains data from 1971.

Finally, we want to assign element name that make sense to each data.

``` r
names(df.current)=ls_filenames # assign name for each list element: corresponding file names
```

Now we could call data from focal year with the file names, directly.

``` r
head(df.current$BCI_2000.csv)
```

    ##   X    datetime       date    ra1    ra2      raw     ra
    ## 1 1 1/1/00 8:55 2000-01-01  0.000  0.000 -999.000 42.397
    ## 2 2 2/1/00 8:55 2000-01-02  0.000  0.000 -999.000  7.895
    ## 3 3 3/1/00 9:24 2000-01-03 50.292 50.292   50.292  0.000
    ## 4 4 4/1/00 9:16 2000-01-04  1.143  1.143    1.143  1.143
    ## 5 5 5/1/00 9:16 2000-01-05 88.138 88.138   88.138 88.138
    ## 6 6 6/1/00 9:21 2000-01-06  0.254  0.508    0.381  0.381
    ##                         comment chk_note chk_fail year
    ## 1                               adjusted Prorated 2000
    ## 2                               adjusted Prorated 2000
    ## 3 Time of measurement estimated adjusted Prorated 2000
    ## 4 Time of measurement estimated     good          2000
    ## 5 Time of measurement estimated     good          2000
    ## 6 Time of measurement estimated     good          2000

`#readfiles` `#R` `#multiplefiles` `#regex` `#list` `#BCI` `#rainfall`
