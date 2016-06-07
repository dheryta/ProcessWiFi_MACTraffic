#!/bin/sh
<<COMMENT1
     1	 frame.time_epoch 
     2	 frame.number 
     3	 prism.did.frmlen 
     4	 prism.did.channel 
     5	 prism.did.mactime 
     6	 prism.did.rate 
     7	 wlan.fc.type_subtype 
     8	 wlan_mgt.ssid 
     9	 wlan.bssid 
    10	 wlan_mgt.ds.current_channel 
    11	 wlan_mgt.qbss.scount 
    12	 wlan.fc.retry 
    13	 wlan.fc.pwrmgt 
    14	 wlan.fc.moredata 
    15	 wlan.fc.frag 
    16	 wlan.duration 
    17	 wlan.ra 
    18	 wlan.ta 
    19	 wlan.sa 
    20	 wlan.da 
    21	 wlan.seq 
    22	 wlan.qos.priority 
    23	 wlan.qos.amsdupresent 
    24	 wlan.fc.type 
    25	 wlan_mgt.fixed.reason_code
    26	 wlan.fc.ds

COMMENT1


pcap_file=$1
output_folder=$2
output_file="/CausalAnalysis.csv"
mac_file=$3
ssid_file=$4
totalMAC=`cat $3|wc -l`
i=1
home_dir=`eval echo ~$USER/`
codePath=$home_dir"/Scripts/CausalAnalysis/CausalAnalysis-Datasets/"

if [ ! -d $output_folder ]; then
mkdir $output_folder
fi

echo "Warning: Delete if this file exists $output_folder$output_file"
touch $output_folder$output_file
while [ $i -le $totalMAC ]; do

SA=`head -n $i $mac_file|tail -1`
echo "Processing MAC: $SA"
echo
echo "Filtering Client Frames"
count_preq=`cat $pcap_file|grep "$SA"|grep "0x04"|wc -l`
if [ $count_preq -gt 0 ]; then
	`awk -F"," 'BEGIN{OFS=",";} {print $1,$7,$8,$9,$13,$17,$18,$19,$20,$25,$26}' $pcap_file | grep "$SA" > /tmp/fileToProcess.csv`
	echo "Filtering Beacon Frames"
	`awk -F"," 'BEGIN{OFS=",";} {if ($7=="0x08") print $8,$9}' $pcap_file > /tmp/beacons.csv`

	python $codePath/Quantify-Causes.py /tmp/fileToProcess.csv /tmp/beacons.csv $SA $ssid_file >> $output_folder$output_file
fi
i=`expr $i + 1`
done



