gnuplot << eor


set terminal png font "Helvetica" 12
set output 'CDF.png'

set datafile separator ","
set key off
set logscale x
set ylabel "Probability"
set xlabel '$2'
plot '$1' using 1:2 lc rgb "black"

eor
