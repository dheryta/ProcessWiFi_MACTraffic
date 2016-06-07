#!/bin/bash
#$1 - Pcap $2 nextSlotpt $3 nextSlotdt $4 - Output CSV-PT $5 - Output CSV-DT $6-edcaEnabled $7-denominator $8-Slot Size

#echo "Parsing PCAP to calculate ATU - $1, $2, and $3"

#`tshark -E separator=, -T fields -e frame.time_epoch -e wlan.fc.type -e wlan.fc.type_subtype -e wlan.qos.priority -e radiotap.datarate -e frame.len -r $1 > /tmp/Frames.csv`

`cat $1 | cut -d, -f1,3,16,15,17,13,6,19,7,21 --output-delimiter=$',' > /tmp/Frames.csv`
codePath="/home/dherytaj/Scripts/CausalAnalysis/ATU/"
#13-RA,15-TA,16-SA,17-DA
#1-time,3-len,6-datarate
#19-QoS Priority,7-type_subtype,21-type
framesCount=`cat /tmp/Frames.csv|wc -l`
if [ $framesCount -gt 0 ]; then
	python $codePath/CalculateAirTimeUtilization-PT.py /tmp/Frames.csv $2 $6 $7 $8 > $4	
	python $codePath/CalculateAirTimeUtilization-DT.py /tmp/Frames.csv $3 $6 $7 $8 > $5	
else
	echo "Empty PCAP"
fi



