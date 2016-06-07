#!/bin/bash
#$1 - Pcap $2 nextSlot $3 - Output CSV 

#echo "Parsing PCAP to calculate ATU - $1, $2, and $3"

#`tshark -E separator=, -T fields -e frame.time_epoch -e wlan.fc.type -e wlan.fc.type_subtype -e wlan.qos.priority -e radiotap.datarate -e frame.len -r $1 > /tmp/Frames.csv`

`cat $1 | cut -d, -f1,3,16,15,17,13,6,19,7,21 --output-delimiter=$',' > /tmp/Frames.csv`
#13-RA,15-TA,16-SA,17-DA
#1-time,3-len,6-datarate
#19-QoS Priority,7-type_subtype,21-type


#time,type,subtype,datarate,len
parent="~/ControllingProbeTraffic/Scripts/ATU_Scripts/"
objFile="CalculateAirTimeUtilization.o"
codeFile="CalculateAirTimeUtilization.c"



#if [ ! -x $parent$objFile ]; then
	gcc $codeFile -o $objFile
#fi

#echo "Calculating Airtime Utilization"
./$objFile /tmp/Frames.csv $2 > $3


