#!/bin/bash
interface=$1
channel=$2
./MonitorMode.sh $interface $channel
 sudo tshark -i $interface -b duration:1800 -w /tmp/`date +%d%m%y`.pcap -F pcap
