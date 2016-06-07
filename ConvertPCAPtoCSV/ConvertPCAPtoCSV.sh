#!/bin/bash
set -x

#for folder in */; do
folder=$1

echo "Current Folder: $folder"
csvfolder="PCAP_CSV"
csv_foldername="$folder$csvfolder"

mergedfolder="Merge"
merged_foldername="$folder$mergedfolder"

if [ ! -d $merged_foldername ]; then
mkdir $merged_foldername
fi

if [ ! -d $csv_foldername ]; then
mkdir $csv_foldername
fi

echo "....$csv_foldername"
i=1

#echo "frame.time_epoch,frame.number,frame.len,radiotap.channel.freq,radiotap.mactime,radiotap.datarate,wlan.fc.type_subtype,wlan.fc.retry,wlan.fc.pwrmgt,wlan.fc.moredata,wlan.fc.frag,wlan.duration,wlan.ra,wlan.bssid,wlan.ta,wlan.sa,wlan.da,wlan.seq,wlan.qos.priority,wlan.qos.amsdupresent" > $csvfolder/$i.csv
isRadioTap=-1
isPrism=-1

	for file in $folder/*.{pcap,pcapng}; do
		if [ $isRadioTap -eq -1 ]; then
		isRadioTap=`tshark -c 1 -r $file -T fields -e frame.protocols|grep "radiotap"|wc -l`
		fi

		if [ $isPrism -eq -1 ]; then
		isPrism=`tshark -c 1 -r $file -T fields -e frame.protocols|grep "prism"|wc -l`
		fi

		if [[ $isPrism -eq 0 ]] && [[ $isRadioTap -eq 1 ]]; then
		echo "Processing: $file with RadioTap Header"
		 `tshark -E separator=, -T fields -e frame.time_epoch -e frame.number -e frame.len -e radiotap.channel.freq -e radiotap.mactime -e radiotap.datarate -e wlan.fc.type_subtype -e wlan_mgt.ssid -e wlan.bssid -e wlan_mgt.ds.current_channel -e wlan_mgt.qbss.scount -e wlan.fc.retry -e wlan.fc.pwrmgt -e wlan.fc.moredata -e wlan.fc.frag -e wlan.duration -e wlan.ra -e wlan.ta -e wlan.sa -e wlan.da -e wlan.seq -e wlan.qos.priority -e wlan.qos.amsdupresent -e wlan.fc.type -e wlan_mgt.fixed.reason_code -e wlan.fc.ds -r $file > $csv_foldername/$i.csv`
		elif [[ $isPrism -eq 1 ]] && [[ $isRadioTap -eq 0 ]]; then
			echo "Processing: $file with Prism Header"
		 `tshark -E separator=, -T fields -e frame.time_epoch -e frame.number -e prism.did.frmlen -e prism.did.channel -e prism.did.mactime -e prism.did.rate -e wlan.fc.type_subtype -e wlan_mgt.ssid -e wlan.bssid -e wlan_mgt.ds.current_channel -e wlan_mgt.qbss.scount -e wlan.fc.retry -e wlan.fc.pwrmgt -e wlan.fc.moredata -e wlan.fc.frag -e wlan.duration -e wlan.ra -e wlan.ta -e wlan.sa -e wlan.da -e wlan.seq -e wlan.qos.priority -e wlan.qos.amsdupresent -e wlan.fc.type -e wlan_mgt.fixed.reason_code -e wlan.fc.ds -r $file > $csv_foldername/$i.csv`
#frame.time_epoch -e wlan.fc.type_subtype -e wlan_mgt.ssid -e wlan.bssid -e wlan_mgt.ds.current_channel -e wlan_mgt.qbss.scount -e wlan.fc.retry -e wlan.ra -e wlan.ta -e wlan.sa -e wlan.da -e  wlan.fc.type

		else
			echo "Unrecognized Header..Exiting Now"	
			exit
		fi
	 `sed -i "s/,,/,EMPTY,/g" $csv_foldername/$i.csv`
	 `sed -i "s/,,/,EMPTY,/g" $csv_foldername/$i.csv`
	 `sed -i "s/,,/,EMPTY,/g" $csv_foldername/$i.csv`
	 `sed -i "s/,,/,EMPTY,/g" $csv_foldername/$i.csv`
	 `sed -i "s/,,/,EMPTY,/g" $csv_foldername/$i.csv`
	 `sed -i "s/,,/,EMPTY,/g" $csv_foldername/$i.csv`
	 `sed -i "s/,,/,EMPTY,/g" $csv_foldername/$i.csv`
	echo "File created $csv_foldername/$i.csv"
	i=`expr $i + 1`
	done
echo "Merging " $csv_foldername " to " $merged_foldername
`cat $csv_foldername/* > $csv_foldername/Merged.csv`
`mv $csv_foldername/Merged.csv $merged_foldername/Merge.csv`
#cd ..
#done


