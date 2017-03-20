#!/bin/bash
folder=$1
if [ -f $folder/*"_discovered_matrix".csv ]; then 
`rm $folder/*"_discovered_matrix".csv`
fi
if [ -f $folder/*"_associated_matrix".csv ]; then 
`rm $folder/*"_associated_matrix".csv`
fi

if [ -f $folder/"AssociationPattern.csv" ]; then
rm $folder/"AssociationPattern.csv"
fi

for mac in `ls -p $folder/ | grep -v /`; do

echo "Processing MAC.................. $mac"
filename=`echo "$mac" | cut -d'.' -f1`


if [ ! -d $folder/$filename"_jaccard" ]; then
mkdir $folder/$filename"_jaccard"
else
rm $folder/$filename"_jaccard"/*
fi

#Unique Responding BSSIDs
`awk -F']' '{print $1}' $folder/$mac | paste -sd,| tr -d [ | tr , "\n"|sort|uniq > /tmp/unprocessed_UniqueRespondingBSSIDs.csv`

`cat /tmp/unprocessed_UniqueRespondingBSSIDs.csv| tr -d " " | sed '/^$/d'|sort|uniq > cat /tmp/UniqueRespondingBSSIDs.csv`
#Unique Associated BSSIDs
`awk -F']' '{print $2}' $folder/$mac | paste -sd,| tr -d [ | tr , "\n"|sort|uniq > /tmp/unprocessed_UniqueAssociatedBSSIDs.csv`
`cat /tmp/unprocessed_UniqueAssociatedBSSIDs.csv| tr -d " " | sed '/^$/d'|sort|uniq > /tmp/UniqueAssociatedBSSIDs.csv`


#Above files have unique responding and associated SSIDs per client for #days of experiment

totalRespondingBSSIDs=`cat /tmp/UniqueRespondingBSSIDs.csv | wc -l`
totalAssociatedBSSIDs=`cat /tmp/UniqueAssociatedBSSIDs.csv | wc -l`

echo $totalAssociatedBSSIDs,$totalRespondingBSSIDs  >> $folder/"AssociationPattern.csv"

`cp /tmp/UniqueRespondingBSSIDs.csv $folder/$filename"_jaccard"/`
`cp /tmp/UniqueAssociatedBSSIDs.csv $folder/$filename"_jaccard"/`

totalLines=`cat $folder/$mac | wc -l`

j=1
while [ $j -le $totalLines ]; do

	i=1
	discovered_associated_bssid=`head -n $j $folder/$mac|tail -1` #Extract the line j
	

	lineToBeProcessed=`echo $discovered_associated_bssid | awk -F']' '{print $1}'|tr -d '['` #Split the line
	

	#filename=`echo "$folder/$mac" | cut -d'.' -f1`
	
	while [ $i -le $totalRespondingBSSIDs ]; do
		bssid=`head -n $i /tmp/UniqueRespondingBSSIDs.csv|tail -1`

		entry=`echo $lineToBeProcessed | grep $bssid | wc -l`
                echo -n $entry, >> $folder/$filename"_jaccard"/"discovered_matrix".csv
		i=`expr $i + 1`
	done
	echo  >>$folder/$filename"_jaccard"/"discovered_matrix".csv

	i=1

	lineToBeProcessed=`echo $discovered_associated_bssid | awk -F']' '{print $2}'|tr -d '['` #Split the line
	while [ $i -le $totalAssociatedBSSIDs ]; do
		bssid=`head -n $i /tmp/UniqueAssociatedBSSIDs.csv|tail -1`

		entry=`echo $lineToBeProcessed | grep $bssid | wc -l`
                echo -n $entry, >> $folder/$filename"_jaccard"/"associated_matrix".csv
		i=`expr $i + 1`
	done
	echo >> $folder/$filename"_jaccard"/"associated_matrix".csv

j=`expr $j + 1`

done

done
