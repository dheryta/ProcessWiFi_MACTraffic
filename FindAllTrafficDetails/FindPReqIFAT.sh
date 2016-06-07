#!/bin/bash
#$1 - PCAP $2 $Folder
#This script requires merged pcap converted to csv

filename=$1
Folder=$2
MACs=$3

if [ ! -d $Folder ]; then
mkdir $Folder
fi


echo "tshark Frame Sequence $filename"

cat $filename | grep 0x04 | cut -d',' -f1 > /tmp/IFAT_Preq.csv #This generates frame arrival times of probe requests


awk 'NR==1{s=$1;next}{print $1-s;s=$1}' /tmp/IFAT_Preq.csv > $Folder/ProbingIFAT.csv
#Plot CDF
python PlotCDF.py $Folder/ProbingIFAT.csv
mv CDFIFAT.csv $Folder/CDF-IFAT-AllPReq.csv
mv CDFIFAT.png $Folder/CDF-IFAT-AllPReq.png

totalMAC=`cat $MACs|wc -l`
i=1
while [ $i -le $totalMAC ]; do

mac=`head -n $i $MACs|tail -1`

cat $filename | grep $mac | grep 0x04 | cut -d',' -f1 > /tmp/IFAT_Preq.csv

awk 'NR==1{s=$1;next}{print $1-s;s=$1}' /tmp/IFAT_Preq.csv > $Folder/ProbingIFAT.csv
#Plot CDF
python PlotCDF.py $Folder/ProbingIFAT.csv
mv CDFIFAT.csv $Folder/$mac.csv
mv CDFIFAT.png $Folder/$mac.png
i=`expr $i + 1`
done


