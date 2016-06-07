#!/bin/sh
#1-parent folder of pcap required it should end with /
#2-file that contains all dates to be processed required
pcap_folder=$1
date_file=$2

while read -r date; do
	echo $date
	pcap_csv="/PCAP_CSV/"
	folder=$pcap_folder$date$pcap_csv
	echo $folder
	`./MergePCAPs.sh $folder`
done < $date_file
