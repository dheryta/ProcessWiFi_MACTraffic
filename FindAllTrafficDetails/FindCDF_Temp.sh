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

CDF="_CDF"
FrameDetails="_FrameDetails"


IFAT="IFAT.csv"
Size="Size.csv"
Rate="Rate.csv"

ifatVar="_IFAT"
sizeVar="_Size"
rateVar="_Rate"

IFATFile=$frameType$IFAT
RateFile=$frameType$Rate
SizeFile=$frameType$Size

outputFolder=$dateToProcess$CDF
inputFolder=$dateToProcess$FrameDetails

if [ ! -d $outputFolder ]; then
mkdir $outputFolder
fi
echo "....Processing Date: $dateToProcess"


#Plot CDF
./PlotUsingGnuPlot.sh ./$outputFolder/CDF-Size-$frameType.csv $frameType$sizeVar
mv CDF.png ./$outputFolder/CDF-Size-$frameType.png

./PlotUsingGnuPlot_log.sh ./$outputFolder/CDF-IFAT-$frameType.csv $frameType$ifatVar
mv CDF.png ./$outputFolder/CDF-IFAT-$frameType.png

./PlotUsingGnuPlot.sh ./$outputFolder/CDF-Rate-$frameType.csv $frameType$rateVar
mv CDF.png ./$outputFolder/CDF-Rate-$frameType.png
