#!/bin/bash
filename=$1
address=$2


cat $filename | grep $address | cut -d, -f7,9 --output-delimiter=$',' > /tmp/frames.csv
lines=`cat /tmp/frames.csv|wc -l`
if [ $lines -ne 0 ]; then
python PwrMgtTriggersAS.py /tmp/frames.csv
else
echo 0
fi



