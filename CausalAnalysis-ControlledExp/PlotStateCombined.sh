gnuplot << eor


set terminal png font "Helvetica" 12
set output '$2'
set key font ",12"
set logscale y
set datafile separator ","
set boxwidth 0.5
set style fill solid 1.0 border -1
set xtics rotate rotate by -60
set bmargin 5
set style data histogram
set style histogram cluster gap 1
set ylabel "Number of probe requests (logscale)"
plot '$1' using 5: xtic(2) with histograms lc rgb "black" title "S0-2.4 GHz", '' using 6 with histograms lc rgb "grey" title "S0-5 GHz", '' using 8 with histograms lc rgb "red" title "S1-2.4 GHz", '' using 9 with histograms lc rgb "green" title "S1-5 GHz"

eor
