#!/bin/bash
#$1 - File $2- Output
gnuplot << eor
set terminal png
set output '$2'
set datafile separator ","

#set key left box samplen 1
#set title 'Probe Responses vs Data For $5 Category '
#set xrange [0:1800]
set yrange [0:100]
#set ytics 0.1
set ylabel "Airtime Utilization Percentage"
set xlabel "Time (seconds)"
#set key right top Left title 'Legend' box 1
#set style  data points 
#set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 pi -1 ps 1.5
#set pointintervalbox 
#'$1' u 1:3 w linespoints title 'Non-enterprise STAs present - Average' lc rgb 'blue' pointtype 4
#'$2' u 1:3 w linespoints title 'Non-enterprise STAs absent - Average' lc rgb 'blue' pointtype 2
plot  '$1' u 1:4 w points title 'Probe Frames' lc rgb 'red' ,\
      

eor

