#!/bin/sh
#parent folder contains the files to be merged

parentFolder=$1

if [ ! -f $parentFolder/Merged.csv ]; then
`cat $parentFolder/* > $parentFolder/Merged.csv`
fi
