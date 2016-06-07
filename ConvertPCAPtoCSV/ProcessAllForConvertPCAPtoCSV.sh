#!/bin/sh
#1-parent folder of pcap required it should end with /
#2-file that contains all dates to be processed required
pcap_folder=$1
date_file=$2

while read -r $date; do
	echo $date
	folderToProcess=$pcap_folder$date
	./ConvertPCAPtoCSV.sh $folderToProcess
done < $date_file
