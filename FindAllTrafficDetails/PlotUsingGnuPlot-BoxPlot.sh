#This script plots the percentage of frames in available frame sizes.
#For each frame size percentage of frames are calculated as per the
#commands in CommandToCountEachSize.txt in the same folder
gnuplot << eor


set terminal png font "Helvetica" 14
set output 'CDF.png'
set datafile separator ","
set boxwidth 0.5
set style fill solid

set ylabel "Percentage of Probe Responses"
set xlabel "Frame Size of Probe Responses (Bytes)"

plot '$1' using 1:3 with boxes title "SIGCOMM '08",  '$2' using 1:3 with boxes title 'IIT-Bombay',  '$3' using 1:3 with boxes title 'IIIT-Delhi'


eor
