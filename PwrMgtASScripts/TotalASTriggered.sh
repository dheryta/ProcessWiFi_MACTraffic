#!/bin/bash
filename=$1
address=$2
declare -a timestamps

cat $filename | grep $address | grep 0x04 | cut -d',' -f1 > /tmp/IFAT_Preq.csv #This generates frame arrival times of probe requests

readarray timestamps < /tmp/IFAT_Preq.csv
i=0
j=0
numberOfTS=${#timestamps[@]}
numberOfTS_j=`expr $numberOfTS - 1`
instances_as=0
ts_to_compare=0.0
ts_current=0.0
while [ $i -lt $numberOfTS ]
do

	ts_to_compare=${timestamps[$i]}

	if [ $i -lt $numberOfTS_j ]; then
	j=`expr $i + 1`
	ts_current=${timestamps[$j]}

	ifat=`echo $ts_current $ts_to_compare  | awk '{print sprintf("%.9f",$1 - $2);}'`


	while [[ "$(echo $ifat '<' 0.06 | bc -l)" -eq 1 ]] && [[ $j -lt $numberOfTS_j ]]; do
		j=`expr $j + 1`		
		ts_current=${timestamps[$j]}
	ifat=`echo $ts_current $ts_to_compare  | awk '{print sprintf("%.9f",$1 - $2);}'`

	done
	i=$j
	else
	i=`expr $i + 1`
	fi
	instances_as=`expr $instances_as + 1`
done

# "Active Scanning Triggered for 
echo $instances_as 



