#!/bin/bash
#$1 - PCAP $2 $Folder
#This script requires merged pcap converted to csv
#/home/dheryta/Scripts/FindAmtofPT/010416_FrameDetails/AckDetails.csv
#/home/dheryta/Scripts/FindAmtofPT/010416_FrameDetails/DataDetails.csv
#/home/dheryta/Scripts/FindAmtofPT/010416_FrameDetails/PReqDetails.csv
#/home/dheryta/Scripts/FindAmtofPT/010416_FrameDetails/PResDetails.csv
#/home/dheryta/Scripts/FindAmtofPT/010416_FrameDetails/ProbeTrafficDetails.csv
#Time, Size, Rate
#This file will generate PDF for Size and Rate
#This file will generate CDF for IFAT using Time

dateToProcess=$1
fileToProcess=$2
frameType=$3
denominator=$4 #1 or 2
CDF="CDF"
FrameDetails="_FrameDetails"
home_dir=`eval echo ~$USER/`
codePath="$home_dir"/Scripts/CausalAnalysis/FindAllTrafficDetails/"

IFAT="IFAT.csv"
Size="Size.csv"
Rate="Rate.csv"

ifatVar="_IFAT"
sizeVar="_Size"
rateVar="_Rate"

IFATFile=$frameType$IFAT
RateFile=$frameType$Rate
SizeFile=$frameType$Size

inputFolder=$dateToProcess
outputFolder=$inputFolder/$CDF$FrameDetails

if [ ! -d $outputFolder ]; then
mkdir $outputFolder
fi
echo "....Processing Date: $dateToProcess"

#Acks
echo "....tshark Frame Sequence $fileToProcess"
cat $inputFolder/$fileToProcess | cut -d',' -f1 > /tmp/$IFAT #This generates frame arrival times
cat $inputFolder/$fileToProcess | cut -d',' -f3 > /tmp/$Rate #This generates frame rate 


cat $inputFolder/$fileToProcess | cut -d',' -f2 > $outputFolder/$SizeFile #This generates frame size
awk 'NR==1{s=$1;next}{print $1-s;s=$1}' /tmp/$IFAT > $outputFolder/$IFATFile
awk -v c=$denominator '{ if ($1 > 1) {print $1/c} else {print $1} }' /tmp/$Rate > $outputFolder/$RateFile

#Plot CDF
python $codePath/PlotCDF.py $outputFolder/$SizeFile 
mv CDF.csv $outputFolder/CDF-Size-$frameType.csv
$codePath/PlotUsingGnuPlot.sh $outputFolder/CDF-Size-$frameType.csv $frameType$sizeVar
mv CDF.png $outputFolder/CDF-Size-$frameType.png

python $codePath/PlotCDF.py $outputFolder/$IFATFile $frameType$ifatVar
mv CDF.csv $outputFolder/CDF-IFAT-$frameType.csv
$codePath/PlotUsingGnuPlot_log.sh $outputFolder/CDF-IFAT-$frameType.csv $frameType$ifatVar
mv CDF.png $outputFolder/CDF-IFAT-$frameType.png

python $codePath/PlotCDF.py $outputFolder/$RateFile 
mv CDF.csv $outputFolder/CDF-Rate-$frameType.csv
$codePath/PlotUsingGnuPlot.sh $outputFolder/CDF-Rate-$frameType.csv $frameType$rateVar
mv CDF.png $outputFolder/CDF-Rate-$frameType.png
