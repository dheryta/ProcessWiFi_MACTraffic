#!/bin/sh

folder=$1
output_file=$2

for file in $folder/*; do
line=`tail -1 $file`
echo $line >> $output_file
done
