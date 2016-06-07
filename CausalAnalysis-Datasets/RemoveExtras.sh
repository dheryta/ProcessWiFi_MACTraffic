#!/bin/sh
grep -v "Loading Frames" CausalAnalysis.csv > t.csv
mv t.csv CausalAnalysis.csv
`sed -i 's/\(\[\|\]\)//g' CausalAnalysis.csv`
`sed -i 's/(//g' CausalAnalysis.csv`
`sed -i 's/)//g' CausalAnalysis.csv`
`sed -i 's/\x27//g' CausalAnalysis.csv`
