#!/bin/bash
#Date=$1
#Folder=~/NormalProbeTraffic_WIPS/$Date/PCAP_CSV
file=$1
#Folder=$2
OutputFolder=$2
#fd="_FrameDetails"

#i=1
#for file in `ls -v $Folder/*`
#do
# echo "Processing: $file"
# filename="${file%.*}"
# underscore="_"
# OutputFolder=$Date$underscore$filename$fd

# if [ ! -d $OutputFolder ]; then
#	mkdir $OutputFolder
# fi

 
#len, rate, subtype, type
 `cat $file | grep '0x04' | cut -d, -f1,3,6 --output-delimiter=$',' > $OutputFolder/PReqDetails.csv `
 `cat $file | grep '0x05' | cut -d, -f1,3,6 --output-delimiter=$',' > $OutputFolder/PResDetails.csv `
 `cat $file | grep '0x1d' | cut -d, -f1,3,6 --output-delimiter=$',' > $OutputFolder/AckDetails.csv `
 `cat $file | grep '0x28\|0x20' | cut -d, -f1,3,6 --output-delimiter=$',' > $OutputFolder/DataDetails.csv `
 `cat $file | grep '0x04\|0x05' | cut -d, -f1,3,6 --output-delimiter=$',' > $OutputFolder/ProbeTrafficDetails.csv `


# i=`expr $i + 1`
#done
