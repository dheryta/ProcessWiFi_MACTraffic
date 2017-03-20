gnuplot << eor


set terminal png font "Helvetica" 14
set output 'CDF.png'

set datafile separator ","

set logscale x
set key bottom
set ylabel "Probability"
set xlabel "Probe Responses Inter Frame Arrival Times (IFAT - seconds)"

plot '$1' using 1:2 with linespoints ls 1 title "SIGCOMM'08", '$2' using 1:2 with linespoints ls 2 title "IIT-Bombay", '$3' using 1:2 with linespoints ls 3 title "IIIT-Delhi"

eor
