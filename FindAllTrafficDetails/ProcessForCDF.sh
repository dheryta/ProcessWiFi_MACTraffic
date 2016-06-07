#!/bin/bash
#input - date
#dateToProcess=$1
folder=$1
denominator=$2
codePath="/home/dherytaj/Scripts/CausalAnalysis/FindAllTrafficDetails/"

ackFile="AckDetails.csv"
dataFile="DataDetails.csv"
preqFile="PReqDetails.csv"
presFile="PResDetails.csv"
ptFile="ProbeTrafficDetails.csv"

#for folder in `ls -v $dateToProcess/`; do

echo "...Processing ACKs"
$codePath/FindCDF-AckDataPT.sh $folder $ackFile ACK $denominator

echo "...Processing Data"
$codePath/FindCDF-AckDataPT.sh $folder $dataFile Data $denominator

echo "...Processing Preq"
$codePath/FindCDF-AckDataPT.sh $folder $preqFile ProbeRequests $denominator

echo "...Processing Pres"
$codePath/FindCDF-AckDataPT.sh $folder $presFile ProbeResponses $denominator

echo "...Processing Probe Traffic"
$codePath/FindCDF-AckDataPT.sh $folder $ptFile ProbeTraffic $denominator
#done
