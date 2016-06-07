gnuplot << eor


set terminal png font "Helvetica" 12
set output '$2'
set logscale y
set datafile separator ","
set boxwidth 0.5
set style fill solid 1.0 border -1
set xtics rotate rotate by -60
set bmargin 5
set style data histogram
set style histogram cluster gap 1
set ylabel "Number of probe requests (logscale)"
plot '$1' using 6: xtic(2) title "2.4 GHz" with histograms lc rgb "black", '' using 8 title "5 GHz" with histograms lc rgb "grey"

eor
