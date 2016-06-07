#!/bin/bash
#Date=$1
file=$1
#Folder=$2
Output_Folder=$2

if [ ! -d $Output_Folder ]; then
mkdir $Output_Folder
fi

#i=1
#for file in `ls -v $Folder/*`
#do
 echo "Processing: $file"
 `cat $file | cut -d, -f7,24 --output-delimiter=$',' > /tmp/$i.csv`
# `tshark -E separator=, -T fields -e frame.time -e wlan.fc.type_subtype -r $file > tmp/$i.csv`
# `sed -i "s/  */ /g" tmp/$i.csv`
# timestamp=`cut -d' ' -f4 tmp/$i.csv|head -1`
 total_frames=`(cat /tmp/$i.csv | wc -l)`
 probe_frames=`(cat /tmp/$i.csv| grep '0x04\|0x05' | wc  -l)`

 data_frames=`(cat /tmp/$i.csv| grep '0x28\|0x20' | wc  -l)`

 type_data_frames=`awk -F, '{ if ($2 == 2) print $0 }' /tmp/$i.csv |wc -l`
 type_mgmt_frames=`awk -F, '{ if ($2 == 0) print $0 }' /tmp/$i.csv |wc -l`
 type_ctrl_frames=`awk -F, '{ if ($2 == 1) print $0 }' /tmp/$i.csv |wc -l`

 if [ $total_frames -gt 0 ]; then
 percentageDataOnTotal=$(echo "scale=10; 100*$data_frames/$total_frames" | bc)
 percentageProbeOnTotal=$(echo "scale=10; 100*$probe_frames/$total_frames" | bc)
 else
 percentageDataOnTotal=0
 percentageProbeOnTotal=0
 fi

 if [ $type_data_frames -gt 0 ]; then
 percentageProbeOnData=$(echo "scale=10; 100*$probe_frames/$type_data_frames" | bc)
 else
 percentageProbeOnData=0
 fi

 if [ $type_ctrl_frames -gt 0 ]; then
 percentageProbeOnControl=$(echo "scale=10; 100*$probe_frames/$type_ctrl_frames" | bc)
 else
 percentageProbeOnControl=0
 fi

 if [ $type_mgmt_frames -gt 0 ]; then
 percentageProbeOnMgmt=$(echo "scale=10; 100*$probe_frames/$type_mgmt_frames" | bc)
 else
 percentageProbeOnMgmt=0
 fi


echo $total_frames,$probe_frames,$data_frames,$type_data_frames,$type_mgmt_frames,$type_ctrl_frames,$percentageDataOnTotal,$percentageProbeOnTotal,$percentageProbeOnData,$percentageProbeOnControl,$percentageProbeOnMgmt > $Output_Folder/FrameCounts.csv
# i=`expr $i + 1`
#done
