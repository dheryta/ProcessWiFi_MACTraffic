#!/bin/sh
sudo ip link set $1 down
sudo iw dev $1 set type monitor
sudo rfkill unblock wifi
sudo ip link set $1 up
sudo iw dev $1 set channel $2 HT20

