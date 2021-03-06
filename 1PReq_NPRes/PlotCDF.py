#!/usr/bin/env python
import numpy as np
import sys

import matplotlib.pyplot as plt

data = np.loadtxt(str(sys.argv[1]))

sorted_data = np.sort(data)

yvals=np.arange(len(sorted_data))/float(len(sorted_data))

s = np.vstack((sorted_data,yvals)).T
np.savetxt('CDF.csv', s, delimiter=",",fmt='%.6f')
#f=plt.plot(sorted_data,yvals)
#plt.xscale('log');
#plt.show()
#plt.savefig('CDFIFAT.png')
