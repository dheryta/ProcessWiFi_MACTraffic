#!/bin/bash

folder=$1 #Date being processed

merged="Merged.csv"
filename=$folder$merged
#cd ~/PwrMgtASScripts
#For every day, for each address do the following 
totalMAC=`cat MACs.txt|wc -l`
i=1

if [ -f $filename ]; then
rm $filename
fi

#Merge PCAPs
`touch $filename`
files=`ls $folder|wc -l`
files=`expr $files - 1`
j=1
while [ $j -le $files ]; do
  `cat $folder/$j.csv >> $filename`
j=`expr $j + 1`	
done


echo $filename
while [ $i -le $totalMAC ]; do

mac=`head -n $i MACs.txt|tail -1`

total=`./TotalASTriggered.sh $filename $mac`

pmas=`./PwrMgtTriggersAS.sh $filename $mac`

echo "$mac,$total,$pmas"
i=`expr $i + 1`
done
