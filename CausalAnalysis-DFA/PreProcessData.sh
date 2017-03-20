#!/bin/bash
###Frame Sequence###
#Code to debug
#  if [ $check1 -eq 1 ] && [ $check2 -eq 1 ]; then
#	echo $bmiss_interval_count
#	echo $c_ndfOff_count
#	echo $ack_count
#    read
#   fi

debugFrameTime=1471827331.332441000
#echo "Preprocessing started for $client_mac"
#Input fileName filtered with client MAC in addr. ap mac, ap ssid and client mac
fileToProcess=$1
windowFile="//tmp//window.csv"
beaconFile="//tmp//beacons_arrival.csv"
beaconWindowFile="//tmp//beaconWindow.csv"
prevWindowFile="//tmp//prevWindow.csv"
class3Frames=("0x20" "0x21" "0x22" "0x23" "0x24" "0x25" "0x26" "0x27" "0x28" "0x29" "0x2a" "0x2b" "0x2c" "0x2e" "0x2f" "0x1a" "0x18" "0x19" "0x0d" "0x0e")
ap_mac=$2
client_mac=$3
ap_ssid=$4
BI=0.105
probeRequest="0x04"
beacon="0x08"
echo "Processing MAC $client_mac"
`cat $fileToProcess | grep $probeRequest | awk -F"," '{print $1}' > /tmp/preq_arrival_time.csv`
`cat $fileToProcess | grep $beacon | awk -F"," '{print $1}' > $beaconFile`
`awk -F"," -v OFS="," 'NR==1{s=$1;next}{print $1,$1-s;s=$1}' /tmp/preq_arrival_time.csv > /tmp/IFAT_PReq.csv`
last_preq=`tail -1 /tmp/preq_arrival_time.csv`
`awk -F"," -v interval=1 '{ if ($2 >= interval) print NR - 1 }' /tmp/IFAT_PReq.csv > /tmp/p_active_scanning.csv`
line_nos=(`cat /tmp/p_active_scanning.csv`)
if [ -f /tmp/active_scanning.csv ]; then
rm /tmp/active_scanning.csv
fi

for l in "${line_nos[@]}"
do
   t=`awk -F"," -v line=$l '{ if (NR == line) print $1 }' /tmp/IFAT_PReq.csv >> /tmp/active_scanning.csv`
done

echo $last_preq >> /tmp/active_scanning.csv

#/tmp/active_scanning.csv contains the line number of last probe request seen when one cycle of active scanning was triggered. 
#Now we need to get timestamps for retrieving the window
#Step 1: Get the timestamp corresponding to this line number- this the end time of the window
#Step 2: Subtract 1 from the end time to get the start time of the window
#Step 3: if new start time is <= last end time, then overlap occurred
#Step 4: if overlap occurred then get the line number of last end time from the fileToProcess.csv, 
#Step 5: line to process, new start line number = line number found above + 1, get the time corresponding to this new start line number this will be the start time now

preq_time=(`cat /tmp/active_scanning.csv`)
#window to consider probe requests preq_loc-20 and preq_loc+20
offset_s=1
offset_e=1
prevStart=-1
prevEnd=-1
window_overlap=0
MAX_BEACON_MISS=8
for time in "${preq_time[@]}"
do
   index=`expr ${#searchString}  - 1`
   size=${#searchString} 
   newsearchString=""
B_Added=0
C_Added=0
A_Added=0
F_Added=0
   while [ $index -ge 0 ]; do
	char=`echo ${searchString:$index:1}`
	if [ "$char" == "B" ] && [ $B_Added -eq 0 ]; then
		newsearchString=$newsearchString"B"
		B_Added=1
	elif [ "$char" == "C" ] && [ $C_Added -eq 0 ]; then
		newsearchString=$newsearchString"C"
		C_Added=1
	#elif [ "$char" == "I" ]; then
	#	newsearchString="I"
	#	break;
	elif [ "$char" == "A" ] && [ $A_Added -eq 0 ]; then
		newsearchString=$newsearchString"A"
		A_Added=1
	elif [ "$char" == "F" ] && [ $F_Added -eq 0 ]; then
		newsearchString=$newsearchString"F"
		 F_Added=1
	fi
   index=`expr $index - 1`
   done

   substring="G"
   presentG=(`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`)
   len_G=${#presentG[@]}
  if [ -n $len_G ] && [ $len_G -gt 0 ]; then
	newsearchString=$newsearchString"G"
  fi		


searchString=$newsearchString


end=$time
   prevValid=`echo $prevEnd'>'-1 | bc -l`	
   if [ $prevValid -eq 1 ]; then
	   #window_overlap=`echo $start'<='$prevEnd | bc -l`	
	   start=$prevEnd
	   `awk -F"," -v s=$start -v e=$end '{ if ($1 > s && $1 <= e) print; }' $fileToProcess > $windowFile`
	   `awk -F"," -v s=$start -v e=$end '{ if ($1 > s && $1 <= e) print; }' $beaconFile > $beaconWindowFile`
   else
	   start=`echo "scale=10; $end - $offset_s"|bc`
	   `awk -F"," -v s=$start -v e=$end '{ if ($1 >= s && $1 <= e) print; }' $fileToProcess > $windowFile`
	   `awk -F"," -v s=$start -v e=$end '{ if ($1 >= s && $1 <= e) print; }' $beaconFile > $beaconWindowFile`
   fi



#A	Non-Class 3 Frame
#	c3_frames=0
#	c=0
#	for i in "${class3Frames[@]}"
#	do
#	   echo $i
#	   c=`cat $windowFile | grep -c $i`
#	   c3_frames=`expr $c3_frames + $c`
#	done
#echo $c3_frames
#read
#        totalFrames=`cat $windowFile | wc -l`
#	ackFrames=`cat $windowFile | grep -c "0x1d" `
#	probeFrames=`cat $windowFile | grep -c -e "0x04" -e "0x05"`
#	non_c3_frames=`expr $totalFrames - $c3_frames`
#	non_c3_frames=`expr $c3_frames - $ackFrames`
#	non_c3_frames=`expr $c3_frames - $probeFrames`

#	if [ $non_c3_frames -gt 0 ]; then
#		searchString=$searchString"A"
#	fi

#B	UnSuccessfull Association/Authentication/Reassoc/deauth
#D	Successfull Association/Authentication/Reassoc/Class 3 Frames
        assoc_response="0x01"
	assoc_response_status="0x00"
	deauth="0x0c"
	reassoc_response="0x03"
	deauth_count=0
	assoc_count=0

	`awk -F"," -v deauth=$deauth -v ap_mac=$ap_mac -v client_mac=$client_mac  '{ if ($2 == deauth && $8 == ap_mac && $9 == client_mac) print $0 }' $windowFile > /tmp/deauth.csv`
	deauth_count=`cat /tmp/deauth.csv | wc -l`

	`awk -F"," -v assoc=$assoc_response -v reassoc=$reassoc_response -v assoc_status=$assoc_response_status -v client_mac=$client_mac  '{ if (($2 == assoc || $2 == reassoc) && ($11 == assoc_status) && $9 == client_mac) print $0 }' $windowFile > /tmp/success_association.csv`
	`awk -F"," -v assoc=$assoc_response -v reassoc=$reassoc_response -v assoc_status=$assoc_response_status -v client_mac=$client_mac  '{ if (($2 == assoc || $2 == reassoc) && !($11 == assoc_status) && $9 == client_mac) print $0 }' $windowFile > /tmp/fail_association.csv`

	unsuccess_assoc_count=`cat /tmp/fail_association.csv | wc -l`
	success_assoc_count=`cat /tmp/success_association.csv | wc -l`

	if [ $deauth_count -eq 0 ] && [ $success_assoc_count -gt 0 ]; then
		searchString=$searchString"D"
	fi
	if [ $deauth_count -gt 0 ] && [ $success_assoc_count -eq 0 ]; then
		searchString=$searchString"B"
	fi
#C	Class 3 Frames
	c3_frames=0
	c=0
	for i in "${class3Frames[@]}"
	do
	   :
	   c=`cat $windowFile | grep -c -e $i`
	   c3_frames=`expr $c3_frames + $c`
	done
	
	if [ $c3_frames -gt 0 ]; then
		searchString=$searchString"C"
	fi	

#E	Signal Values in frames start decreasing
#http://www.cisco.com/en/US/docs/wireless/controller/7.4/configuration/guides/system_management/config_system_management_chapter_01100.html
	# If the client’s average received signal power dips below this threshold, reliable communication is usually impossible. Therefore, clients must already have found and roamed to another access point with a stronger signal before the minimum RSSI value is reached. The range is –80 to –90 dBm. The default is –85 dBm.
	#When the RSSI drops below the specified value, the client must be able to roam to a better access point within the specified transition time. This parameter also provides a power-save method to minimize the time that the client spends in active or passive scanning. For example, the client can scan slowly when the RSSI is above the threshold and scan more rapidly when the RSSI is below the threshold. The range is –70 to –77 dBm. The default is –72 dBm.

	`cat $windowFile | awk -F"," -v mac=$client_mac '{if ($7 == mac || $8 == mac) print $13}' > /tmp/signal_values.csv`
	average_signal=`awk '{ total += $1; count++ } END { print total/count }' /tmp/signal_values.csv`
	std_dev=(`awk -vM=$average_signal '{for(i=1;i<=NF;i++){sum+=($i-M)*($i-M)};print sqrt(sum/NF)}' /tmp/signal_values.csv`)
	signal_threshold=-72
	deviation_threshold=12
	signal_compare=`echo $signal_threshold'>'$average_signal | bc -l`	
	deviation_compare=`echo ${std_dev[-1]}'>'$deviation_threshold | bc -l`		
#echo ${std_dev[-1]}
#echo $average_signal
#read
#TODO:	if [ $signal_compare -eq 1 ] || [ $deviation_compare -eq 1 ]; then
	if [ $signal_compare -eq 1 ]; then  
		searchString=$searchString"E"
	fi

#F	Frame arrival rate > #10 frames per second
#G	Frame arrival rate <= #2 frames per second
	`cat $windowFile | awk -F"," -v mac=$client_mac '{if ($7 == mac || $8 == mac) print $1}' > /tmp/frame_arrival_time.csv`
	numberOfFrames=`cat /tmp/frame_arrival_time.csv | wc -l`
	firstTime=`head -1 /tmp/frame_arrival_time.csv`
	lastTime=`tail -1 /tmp/frame_arrival_time.csv`
	timeDiff=`echo $lastTime'-'$firstTime | bc -l`
	frameArrivalRate=`echo $numberOfFrames'/'$timeDiff | bc -l`
	ifF=`echo $frameArrivalRate'>'2 | bc -l`
	ifG=`echo $frameArrivalRate'<='2 | bc -l`
	
	if [ -n $ifF ] && [ $ifF -eq 1 ]; then
		searchString=$searchString"F"
	fi

	if [ -n $ifG ] && [ $ifG -eq 1 ]; then
		searchString=$searchString"G"
	fi

#H	AP deauth
	`awk -F"," -v deauth=$deauth -v ap_mac=$ap_mac -v client_mac=$client_mac '{ if (($2 == deauth) && $8 == ap_mac && $9 == client_mac) print $0 }' $windowFile > /tmp/ap_deauth.csv`
	ap_deauth_count=`cat /tmp/ap_deauth.csv | wc -l`

	
	if [ $ap_deauth_count -gt 0 ]; then
		searchString=$searchString"H"
	fi	

#I	"UnAckd NDF PS=0 or IFAT of Beacon more than BI"
	`awk -F"," -v ndf1=$ndf1 -v ndf2=$ndf2 -v client_mac=$client_mac -v PM_Off=$PM_Off '{ if (($2 == ndf1 || $2 == ndf2) && $8 == client_mac && $5 == PM_Off) print $0 }' $windowFile > /tmp/client_ndf_off.csv`
	c_ndfOff_count=`cat /tmp/client_ndf_off.csv | wc -l`
	ack="0x1d"
	`awk -F"," -v ack=$ack -v client_mac=$client_mac '{ if (($2 == ack) && $6 == client_mac) print $0 }' $windowFile > /tmp/client_ack.csv`
	ack_count=`cat /tmp/client_ack.csv | wc -l`
	beacon="0x08"

	`awk 'NR==1{s=$1;next}{print $1-s;s=$1}'  $beaconWindowFile > /tmp/IFAT_beacon.csv`
	`awk -F"," -v BI=$BI '{ if ($1 > BI) print $1 }' /tmp/IFAT_beacon.csv > /tmp/beacon_miss.csv`
	bmiss_interval_count=`cat /tmp/beacon_miss.csv | wc -l`
        beacon_count=`cat $beaconWindowFile | wc -l`

	if [ $beacon_count -eq 0 ] || [ $bmiss_interval_count -gt $MAX_BEACON_MISS ]; then
		searchString=$searchString"I"
	fi
	
	if [ $c_ndfOff_count -gt 0 ] && [ $ack_count -eq 0 ]; then
		searchString=$searchString"I"
	fi
		


#J	Frame Retries increase or Loss of acks increase or Data rate reduced
	`cat $windowFile | awk -F"," -v mac=$client_mac '{if ( ($7 == mac || $8 == mac) && ($14 == 0)) print $1}' > /tmp/frame_fresh.csv`
	`cat $windowFile | awk -F"," -v mac=$client_mac '{if ( ($7 == mac || $8 == mac) && ($14 == 1)) print $1}' > /tmp/frame_retry.csv`
	frameRetryCount=`cat /tmp/frame_retry.csv | wc -l`
	frameFreshCount=`cat /tmp/frame_fresh.csv | wc -l`
	totalFrameCount=`expr $frameRetryCount + $frameFreshCount`
	percentRetry=`echo $frameRetryCount'/'$totalFrameCount | bc -l`
	percentRetryTrue=`echo $percentRetry'>='0.5 | bc -l`
	if [ $percentRetryTrue -eq 1 ]; then
		searchString=$searchString"J"
	fi	

#N	Client deauth

	`awk -F"," -v deauth=$deauth -v client_mac=$client_mac -v ap_mac=$ap_mac '{ if (($2 == deauth) && $8 == client_mac && $9 == ap_mac) print $0 }' $windowFile > /tmp/client_deauth.csv`
	c_deauth_count=`cat /tmp/client_deauth.csv | wc -l`

	if [ $c_deauth_count -gt 0 ]; then
		searchString=$searchString"N"
	fi	


#K	Probe Requests
#L	Probe Requests directed to AP
#M	No Probe Requests
	c_noap=`cat $windowFile|grep $probeRequest|grep -c -v $ap_ssid`
	c_ap=`cat $windowFile|grep $probeRequest|grep -c $ap_ssid`

	if [ $c_ap -gt 0 ] && [ $c_noap -gt 0 ]; then
		searchString=$searchString"K"
	elif [ $c_ap -gt 0 ] && [ $c_noap -eq 0 ]; then
		searchString=$searchString"L"
	elif [ $c_ap -eq 0 ] && [ $c_noap -gt 0 ]; then
		searchString=$searchString"K"
	elif [ $c_ap -eq 0 ] && [ $c_noap -eq 0 ]; then
		searchString=$searchString"M"
	fi	
: '
#R	Not Unknown - not A,C,K,M
	lenSearchStr=${#searchString}
	substring="A"
	presentA=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="C"
	presentC=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="K"
	presentK=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="M"
	presentM=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	
	if [ $lenSearchStr -gt 0 ] && [ ! -n $presentA ] && [ ! -n $presentC ] && [ ! -n $presentK ] && [ ! -n $presentM ]; then
		searchString="R"$searchString
	fi		

#S	Not Unassociated - A and not D,K,M
	substring="A"
	presentA=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="D"
	presentD=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="K"
	presentK=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="M"
	presentM=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	
	if [ -n $presentA ] && [ ! -n $presentD ] && [ ! -n $presentK ] && [ ! -n $presentM ]; then
		searchString=$searchString"S"
	fi		


#T	Not Associated - C and not E,G,F,K,M
	substring="C"
	presentC=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="E"
	presentE=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="G"
	presentG=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="F"
	presentF=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="K"
	presentK=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="M"
	presentM=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	
	if [ -n $presentC ] && [ ! -n $presentE ] && [ ! -n $presentG ] && [ ! -n $presentF ] && [ ! -n $presentK ] && [ ! -n $presentM ]; then
		searchString=$searchString"T"
	fi		

#U	Not Moving - E and not K,M
	substring="E"
	presentE=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="K"
	presentK=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="M"
	presentM=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	
	if [ -n $presentE ] && [ ! -n $presentK ] && [ ! -n $presentM ]; then
		searchString=$searchString"U"
	fi		


#V	Not PowerSave - G and not F,H,I,J,K,M
	substring="G"
	presentG=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="F"
	presentF=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="H"
	presentH=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="I"
	presentI=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="J"
	presentJ=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="K"
	presentK=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="M"
	presentM=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	
	if [ -n $presentG ] && [ ! -n $presentF ] && [ ! -n $presentH ] && [ ! -n $presentI ] && [ ! -n $presentJ ] && [ ! -n $presentK ] && [ ! -n $presentM ]; then
		searchString=$searchString"V"
	fi		


#W	Not Active - F and not G,H,I,J,K,M
	substring="F"
	presentF=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`

	substring="G"
	presentG=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="H"
	presentH=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="I"
	presentI=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="J"
	presentJ=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="K"
	presentK=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="M"
	presentM=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	
	if [ -n $presentF ] && [ ! -n $presentG ] && [ ! -n $presentH ] && [ ! -n $presentI ] && [ ! -n $presentJ ] && [ ! -n $presentK ] && [! -n $presentM ]; then
		searchString=$searchString"W"
	fi		

#X	Not CMM - H and not K,M
	substring="H"
	presentH=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="K"
	presentK=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="M"
	presentM=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	
	if [ -n $presentH ] && [ ! -n $presentK ] && [ ! -n $presentM ]; then
		searchString=$searchString"U"
	fi		

#Y	Not BM - I and not L, M
	substring="I"
	presentI=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="K"
	presentK=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="M"
	presentM=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	
	if [ -n $presentI ] && [ ! -n $presentK ] && [ ! -n $presentM ]; then
		searchString=$searchString"Y"
	fi		

#Z	Not CQM - J and not K,M
	substring="J"
	presentJ=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="K"
	presentK=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	substring="M"
	presentM=`echo $searchString|grep -b -o $substring|awk -F":" '{print $1}'`
	
	if [ -n $presentJ ] && [ ! -n $presentK ] && [ ! -n $presentM ]; then
		searchString=$searchString"Z"
	fi		

'

   prevStart=$start
   prevEnd=$end

echo $start, $end, "\""$searchString"\""

done


