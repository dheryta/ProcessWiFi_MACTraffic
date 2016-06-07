#!/bin/sh
fileToProcess=$1
outputFolder=$2
denominator=$3
codePath="/home/dherytaj/Scripts/CausalAnalysis/FindAllTrafficDetails/"

$codePath/FilterFrameDetails.sh $fileToProcess $outputFolder
inputFolder=$outputFolder
$codePath/ProcessForCDF.sh $inputFolder $denominator
