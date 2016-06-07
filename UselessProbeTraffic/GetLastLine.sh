#!/bin/sh
folder=$1
outputFile=$2

if [ -f $outputFile ];  then
rm $outputFile
fi

for file in `ls -v $folder/*.csv`
do
	tail -1 $file >> $outputFile
done
