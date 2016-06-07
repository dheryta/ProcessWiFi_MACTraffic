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
plot '$1' using 5: xtic(2) with histograms lc rgb "black" title "H1", '' using 8 with histograms lc rgb "grey" title "H5", '' using 11 with histograms lc rgb "red" title "H10", '' using 14 with histograms lc rgb "green" title "H15", '' using 17 with histograms lc rgb "blue" title "H20"

eor
