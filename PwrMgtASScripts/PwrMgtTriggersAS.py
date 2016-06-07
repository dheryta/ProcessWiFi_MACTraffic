#!/usr/bin/python
import sys
from numpy import loadtxt



filename=sys.argv[1]

#Frame Type and Power Management
#frames= open(filename, "r")


frames = open( filename, "r" )  # the "r" is not really needed - default 
framesTable = []

for line in frames:
   row = line.rstrip().split(',')  
   framesTable.append(row)

lines= len(framesTable)
columns= len(framesTable[0])

current=0
isACK=0
isPReq=0
countAS=0
iterations=lines-3

while (current <= iterations):
	isACK=current+1
	isPPReq=current+2
	
	currentFrameType=framesTable[current][0]
	currentPwrMgt=framesTable[current][1]	

	ackFrameType=framesTable[isACK][0]
	ackPwrMgt=framesTable[isACK][1]	

	preqFrameType=framesTable[isPPReq][0]
	preqPwrMgt=framesTable[isPPReq][1]	
	
	
	if ( currentPwrMgt == '1' ) and ( ackFrameType == '0x1d' ) and ( preqFrameType == '0x04' ):
		countAS=countAS + 1

	current=current+1


print countAS
'''
current=0
isACK=0
isPReq=0
countAS=0
totalFrames=`wc -l /tmp/frames.csv | awk -F' ' '{print $1}'`
iterations=`expr $totalFrames - 3`

loop through all frames
read current, next, next2next frames
get their type and pwrmgt


if [[ $currentPwrMgt -eq 1 ]] and [[ "$ackFrameType" == "0x1d" ]] and [[ "$preqFrameType" == "0x04" ]]; then
	countAS=`expr $countAS + 1`
fi

current=`expr $current + 1`
done

#"Total AS due to Power Management:" 
echo $countAS


'''
