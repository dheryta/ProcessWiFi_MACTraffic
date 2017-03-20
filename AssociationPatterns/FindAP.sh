#!/bin/bash
filename=$1
folder=$2 #Date being processed
home_dir=`eval echo ~$USER/`
codePath=$home_dir"Scripts/CausalAnalysis/UselessProbeTraffic/"
out_path_allDays=$3
clients=$4

cat $filename | grep '0x05' | cut -d, -f19,20 --output-delimiter=$',' > /tmp/pres_frames.csv #SA,DA
cat $filename | grep '0x20\|0x28' | cut -d, -f9,19 --output-delimiter=$',' > /tmp/data_frames.csv #BSSID, SA
totalMAC=`cat $clients|wc -l`

if [ ! -d $folder ]; then
mkdir $folder
fi

if [ -f $folder/AllMAC-RespondingBSSIDs.csv ]; then
rm $folder/AllMAC-RespondingBSSIDs.csv
fi
i=1
while [ $i -le $totalMAC ]; do

mac=`head -n $i $clients|tail -1`
echo $mac

cat /tmp/pres_frames.csv | grep $mac > /tmp/mac_pres_frames.csv
`awk -F, -v DA=$mac '{ if ($2 == DA) {print $1} }' /tmp/mac_pres_frames.csv > /tmp/responding_BSSIDs.csv`
responding_bssids=`cat /tmp/responding_BSSIDs.csv | sort | uniq | paste -sd,`


cat /tmp/data_frames.csv | grep $mac > /tmp/mac_data_frames.csv
`awk -F, -v SA=$mac '{ if ($2 == SA) {print $1} }' /tmp/mac_data_frames.csv > /tmp/associated_BSSIDs.csv`
associated_bssids=`cat /tmp/associated_BSSIDs.csv | sort | uniq | paste -sd,`
echo $mac", ["$responding_bssids"], ["$associated_bssids"]" >> $folder/AllMAC-AssociationPatterns.csv

echo "["$responding_bssids"], ["$associated_bssids"]" >> $out_path_allDays/$mac.csv #We are deleting old files in CodeFlow.sh

i=`expr $i + 1`
done
