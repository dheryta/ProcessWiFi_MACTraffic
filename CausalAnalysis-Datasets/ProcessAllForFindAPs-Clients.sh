#!/bin/sh
#1-parent folder of pcap required it should end with / , ~/NormalProbeTraffic_WIPS/
#2-file that contains all dates to be processed required
pcap_folder=$1
date_file=$2
home_dir=`eval echo ~$USER/`
parent_output_folder=$home_dir"/DataAnalysis-IIITD/"
merged_pcap_csv="/PCAP_CSV/Merged.csv"

while read -r date; do
	echo $date
	output_folder=$parent_output_folder$date
	fileToProcess=$pcap_folder$date$merged_pcap_csv
	./FindAPs-Clients.sh $fileToProcess $output_folder
done < $date_file
