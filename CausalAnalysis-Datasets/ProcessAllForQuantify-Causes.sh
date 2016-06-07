#!/bin/sh
#1-parent folder of pcap required it should end with / , ~/NormalProbeTraffic_WIPS/
#2-file that contains all dates to be processed required
#parent_output_folder="~/DataAnalysis-IIITD/CausalQuantification/"

pcap_folder=$1
date_file=$2
output_folder_name="/CausalQuantification"
parent_output_folder=$3
mac_file=$4
merged_pcap_csv="/PCAP_CSV/Merged.csv"

parent_output_folder_combined=$parent_output_folder$output_folder_name

if [ ! -d $parent_output_folder_combined ]; then
mkdir $parent_output_folder_combined
fi

while read -r date; do
	echo $date
	output_folder=$parent_output_folder_combined$date
	fileToProcess=$pcap_folder$date$merged_pcap_csv
	./Quantify-Causes.sh $fileToProcess $output_folder $mac_file
done < $date_file
