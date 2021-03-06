#!/bin/bash
home_dir=`eval echo ~$USER/`
Folder=$home_dir"NormalProbeTraffic_WIPS/"$1 #Date PCAP_CSV being processed
Date=$1
ParentDirectory=$home_dir
ssid=$2

if [ ! -d $ParentDirectory$Date ]; then
mkdir $ParentDirectory$Date
fi

#FindSimilarityIndex.sh folder-to be created(it will have one file corresponding to each MAC) filename-csv file to be searched
i=1
for file in `ls -v $Folder/PCAP_CSV/*`
do
 echo "Processing: $file"
 
 ./FindSimilarityIndex.sh $ParentDirectory$Date/$i $file $ssid
 i=`expr $i + 1`
done
