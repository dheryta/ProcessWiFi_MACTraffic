#!/bin/bash
./PlotBL-PM-S.sh  BL-iPad.csv BL.png
./PlotBL-PM-S.sh  PM-iPad.csv PM.png
./PlotHistoryCombined-24g.sh HistoryCombined-iPad.csv HistoryCombined-24g.png
./PlotHistoryCombined-5g.sh  HistoryCombined-iPad.csv HistoryCombined-5g.png
./PlotStateCombined.sh StateCombined-iPad.csv StateCombined.png

