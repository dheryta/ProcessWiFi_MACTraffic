#!/bin/bash
#$1 - WoR PCAP $2 WR PCAP $3 Slot $4 $Folder
#To find Probe/FDF Ratio in a per second slot
#Probe = Take all probe requests and probe responses in the pcap
#Data = Take only fresh data frames of a particular AC via the BSSID 07:00/07:01


`gcc -g ParsePCAPFor1PReq_NPRes.c -o ParsePCAPFor1PReq_NPRes.o`



WoR=$1
WR=$2
Folder=$3

if [ ! -d $Folder ]; then
mkdir $Folder
fi

echo "tshark Frame Sequence WoR $Folder"
	`tshark -R "(wlan.fc.type_subtype == 0x04 or wlan.fc.type_subtype == 0x05)" -E separator=, -T fields -e frame.time_epoch -e wlan.fc.type_subtype -e wlan.sa -e wlan.da -e frame.len -r $WoR > $Folder/WoR_Probes.csv`

echo "1 Probe Request = N Probe Responses $WoR"
`./ParsePCAPFor1PReq_NPRes.o $Folder/WoR_Probes.csv > $Folder/WoR_1PReq_NPres.csv`
`cat $Folder/WoR_1PReq_NPres.csv >> WoR_Combined.csv`

echo "tshark Frame Sequence WR $Folder"
	`tshark -R "(wlan.fc.type_subtype == 0x04 or wlan.fc.type_subtype == 0x05)" -E separator=, -T fields -e frame.time_epoch -e wlan.fc.type_subtype -e wlan.sa -e wlan.da -e frame.len -r $WR > $Folder/WR_Probes.csv`

echo "1 Probe Request = N Probe Responses $WR"
`./ParsePCAPFor1PReq_NPRes.o $Folder/WR_Probes.csv > $Folder/WR_1PReq_NPres.csv`
`cat $Folder/WR_1PReq_NPres.csv >> WR_Combined.csv`

