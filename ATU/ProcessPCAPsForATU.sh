#!/bin/bash
#$1-Main Folder ex ../NormalProbeTraffic-TPLink-Enterprise $2-Date Folder

#pcapFolder=$1 #CSV Date Folder
csv=$1
outputFolder=$2
home_dir=`eval echo ~$USER/`
codePath=$home_dir"Scripts/CausalAnalysis/ATU/"
edcaEnabled=$3
denominator=$4
slotSize=$5

i=1


if [ ! -d $outputFolder ]; then
	mkdir $outputFolder
fi

csvFiles="*.csv"
nextSlotdt=0
nextSlotpt=0
ptFile="PT.csv"
dtFile="DT.csv"
#for csv in `ls -v $pcapFolder$csvFiles`; do
    echo "Processing $csv"
    frames=`cat $csv|wc -l`
    if [ $frames -ne 0 ]; then
     $codePath/AirtimeUtilization-python.sh $csv $nextSlotpt $nextSlotdt $outputFolder/$ptFile $outputFolder/$dtFile $edcaEnabled $denominator $slotSize
     nextSlotpt=`tail -1 $outputFolder/$ptFile | awk -F, '{print $1}'`
     nextSlotdt=`tail -1 $outputFolder/$dtFile | awk -F, '{print $1}'`
     fi
    
#     i=`expr $i + 1`
#done

#j=1
#files=`expr $i - 1`

#while [ $j -le $files ]; do
#  `cat $outputFolder/$j$ptFile.csv >> $outputFolder/Merged-PT.csv`
#  `cat $outputFolder/$j$dtFile.csv >> $outputFolder/Merged-DT.csv`
#j=`expr $j + 1`	
#done

#./PlotATU.sh $outputFolder/Merged.csv $outputFolder/Merged.png
$codePath/PlotATU_DataFrames.sh $outputFolder/$dtFile $outputFolder/ATU_DataFrames.png
$codePath/PlotATU_ProbeFrames.sh $outputFolder/$ptFile $outputFolder/ATU_ProbeFrames.png


