#!/bin/bash
#reading files line by line for input file ## 20190707 John Park
#input="/path/to/txt/file"
img_path=
out_path=

linecount=0
while IFS= read -r line
do
  #echo "$line"
       tagstr="tag_${line}_" #use curly bracelet to unclude variable inside the string
            ls $img_path | grep $tagstr >> obstreepath.txt ## find a way to automate cp without saving file; xargs?
       #    $((linecount++)) 
       #    echo "$linecount- $line currnet size " 
       #    currwc=$(wc -l obstreepath.txt)
       #    echo "$currwc"
           
done < "$1"

while read -r line; do cp $img_path/$line $out_path; done < obstreepath.txt 

