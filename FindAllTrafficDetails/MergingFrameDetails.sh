#!/bin/bash
folder=./$1

echo "Merging to File: Merged_FrameDetails"
if  [ ! -d Merged_FrameDetails ]; then
	mkdir Merged_FrameDetails
fi
touch Merged_FrameDetails/AckDetails.csv
touch Merged_FrameDetails/DataDetails.csv
touch Merged_FrameDetails/PReqDetails.csv
touch Merged_FrameDetails/PResDetails.csv
touch Merged_FrameDetails/ProbeTrafficDetails.csv

echo $folder
cat $folder/AckDetails.csv >> Merged_FrameDetails/AckDetails.csv
cat $folder/DataDetails.csv >> Merged_FrameDetails/DataDetails.csv
cat $folder/PReqDetails.csv >> Merged_FrameDetails/PReqDetails.csv
cat $folder/PResDetails.csv >> Merged_FrameDetails/PResDetails.csv
cat $folder/ProbeTrafficDetails.csv >> Merged_FrameDetails/ProbeTrafficDetails.csv



