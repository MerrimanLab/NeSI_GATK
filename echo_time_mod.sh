#!/bin/bash
#$1 = directory to get file sizes and modifiation times 
for file in $(ls $1)
do
	echo $file $(stat --format '%s' $file) $(stat --format '%Y' $file)
done
