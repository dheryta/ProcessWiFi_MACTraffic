#!/bin/bash
#$1 - WoR PCAP $2 WR PCAP $3 Slot $4 $Folder
#To find Probe/FDF Ratio in a per second slot
#Probe = Take all probe requests and probe responses in the pcap
#Data = Take only fresh data frames of a particular AC via the BSSID 07:00/07:01


filename=$1
folder=$2 #Output Folder

home_dir=`eval echo ~$USER/`
codePath=$home_dir"Scripts/CausalAnalysis/1PReq_NPRes/"

#tshark -E separator=, -T fields -e frame.time_epoch -e frame.number -e prism.did.frmlen -e prism.did.channel -e prism.did.mactime -e prism.did.rate -e wlan.fc.type_subtype -e wlan_mgt.ssid -e wlan.bssid -e wlan_mgt.ds.current_channel -e wlan_mgt.qbss.scount -e wlan.fc.retry -e wlan.fc.pwrmgt -e wlan.fc.moredata -e wlan.fc.frag -e wlan.duration -e wlan.ra -e wlan.ta -e wlan.sa -e wlan.da -e wlan.seq -e wlan.qos.priority -e wlan.qos.amsdupresent -e wlan.fc.type -e wlan_mgt.fixed.reason_code -e wlan.fc.ds -r $file 
#Time, subtype, ssid, bssid, channel, station_count, ra, ta, sa, da, type
 #1,    7,         8,     9,      10,            11, 17, 18, 19, 20, 24

cat $filename | grep '0x04\|0x05' | awk -v OFS="," -F"," '{print $1, $7, $19, $20, $3}' > /tmp/frames.csv
if [ ! -d $folder ]; then
mkdir $folder
fi

gcc $codePath/ParsePCAPFor1PReq_NPRes_UniqueBSSIDs.c -o $codePath/ParsePCAPFor1PReq_NPRes_UniqueBSSIDs.o
$codePath/ParsePCAPFor1PReq_NPRes_UniqueBSSIDs.o /tmp/frames.csv > $folder/1PReqNPRes_UniqueBSSIDs.csv

gcc $codePath/ParsePCAPFor1PReq_NPRes.c -o $codePath/ParsePCAPFor1PReq_NPRes.o
$codePath/ParsePCAPFor1PReq_NPRes.o /tmp/frames.csv > $folder/1PReqNPRes.csv
