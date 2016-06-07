#!/usr/bin/python
import sys
from numpy import loadtxt


filename=sys.argv[1]
nextSlot=float(sys.argv[2])
edcaEnabled=int(sys.argv[3])
denominator=int(sys.argv[4])
slot=int(sys.argv[5])
#1-time,3-len,6-datarate,19-QoS Priority,7-type_subtype,21-type

#IFS=SIFS/DIFS/AIFS[VO]/AIFS[VI]/AIFS[BK]/AIFS[BE]

#FrameTime = IFS + Preamble + PLCP Header

frames = open( filename, "r" )  # the "r" is not really needed - default 
framesTable = []

for line in frames:
   row = line.rstrip().split(',')  
   framesTable.append(row)

lines= len(framesTable)
columns= len(framesTable[0])

current=0
#Our pcaps have short preamble allowed
ofdmPreamble=16 #us
ofdmPLCPHeader=4 #us
ofdmSIFSTime=10 #us
ofdmSlotTime=9 #us
ofdmDIFSTime=34 #2*SlotTime(9us) + SIFSTime
ofdmAIFSTime=0 #AIFSN[AC]*aSlotTime + aSIFSTime
bkAIFS=73
beAIFS=37
viAIFS=28
voAIFS=28
#slot=5
time=nextSlot

frameTime=0
dataFrames=0
lines=lines-2
while (current < lines):

	currentFrameTime=framesTable[current][0]
	prevFrameTime=currentFrameTime
	currentFrameLen=framesTable[current][1]	
	currentFrameRate=framesTable[current][2]
	currentFrameSubType=framesTable[current][3]	
	currentFrameRA=framesTable[current][4]
	currentFrameTA=framesTable[current][5]	
	currentFrameSA=framesTable[current][6]	
	currentFrameDA=framesTable[current][7]	
	currentFramePriority=framesTable[current][8]	
	currentFrameType=framesTable[current][9]	


	#print "Main While",current,currentFrameTime,prevFrameTime,currentFrameSubType
	#readchar.readchar()
	while ( float(currentFrameTime) - float(prevFrameTime) <= slot and current < lines):		
		#Consider the case of RTS, CTS and Data
		if ( currentFrameSubType == '0x1b' and framesTable[current+1][3] == '0x1c' and (framesTable[current+2][3] == '0x28' or framesTable[current+2][3] == '0x20') and currentFrameTA == framesTable[current+1][4] and float(currentFrameTime) - float(prevFrameTime) <= slot ):
			IFS=ofdmSIFSTime
			current=current+2

			##print "RTS--CTS Block"
			currentFrameTime=framesTable[current][0]
			currentFrameLen=framesTable[current][1]	
			currentFrameRate=framesTable[current][2]
			currentFrameSubType=framesTable[current][3]	
			currentFrameRA=framesTable[current][4]
			currentFrameTA=framesTable[current][5]	
			currentFrameSA=framesTable[current][6]	
			currentFrameDA=framesTable[current][7]	
			currentFramePriority=framesTable[current][8]	
			currentFrameType=framesTable[current][9]	
	
			prevSA=currentFrameTA
			
			#print "FrameTime< Slot, RTS-CTS Case",current,currentFrameTime,prevFrameTime,currentFrameSubType
			#readchar.readchar()
			localFrameCount=0
			while ( (currentFrameSubType == '0x28' or currentFrameSubType == '0x20') and currentFrameSA == prevSA and 	current < lines and float(currentFrameTime) - float(prevFrameTime) <= slot ):
				##print "RTS--CTS Block-While"
				
				current=current + 1
				localFrameCount=localFrameCount+1
				currentFrameSubType=framesTable[current][3]
				if (currentFrameSubType== '0x1d' and currentFrameRA==prevSA):		
					current=current + 1

				
				if (int(currentFrameRate) != 0):
					if (int(currentFrameRate) > 1):
						rate=1000000*float(currentFrameRate)/denominator
						frameTime=frameTime+(int(currentFrameLen)*8)/rate
					else:
						frameTime=frameTime+(int(currentFrameLen)*8)

			
				currentFrameTime=framesTable[current][0]
				currentFrameLen=framesTable[current][1]
				prevSA = currentFrameSA	
				currentFrameRate=framesTable[current][2]
				currentFrameSubType=framesTable[current][3]	
				currentFrameRA=framesTable[current][4]
				currentFrameTA=framesTable[current][5]	
				currentFrameSA=framesTable[current][6]	
				currentFrameDA=framesTable[current][7]	
				currentFramePriority=framesTable[current][8]	
				currentFrameType=framesTable[current][9]
				#print "Current Frame",current,"RTS-CTS Case, considering SIFS for",localFrameCount,"Frames"
				#readchar.readchar()
			
			
			IFS=ofdmSIFSTime*localFrameCount
			totalPreambleTime=localFrameCount*ofdmPreamble
			totalPLCPHeaderTime=localFrameCount*ofdmPLCPHeader
			frameTime=frameTime+IFS+totalPreambleTime+totalPLCPHeaderTime
			dataFrames=dataFrames+localFrameCount
			#print "Frame Time:",frameTime
			

		elif (currentFrameSubType == '0x28' or currentFrameSubType == '0x20' and float(currentFrameTime) - float(prevFrameTime) <= slot ): 
	
			##print "Data block without RTS--CTS"
			#count until next frame is different than QoS
			countBK=0
			countBE=0
			countVI=0
			countVO=0
			countNonQoS=0
			prevSA = currentFrameSA
			##print "Data Block-pprevSA", prevSA
			#print "Checking for Block Ack, elif",current,currentFrameTime,prevFrameTime,currentFrameSubType
			#readchar.readchar()
			localFrameCount=0
			while ( (currentFrameSubType == '0x28' or currentFrameSubType == '0x20') and currentFrameSA == prevSA and 	current < lines and float(currentFrameTime) - float(prevFrameTime) <= slot ):

				current=current + 1
				#print "Current Frame",current
				localFrameCount=localFrameCount+1
				if (float(currentFrameRate) != 0):
					if (float(currentFrameRate) > 1):
						rate=1000000*float(currentFrameRate)/2
						frameTime=frameTime+(int(currentFrameLen)*8)/rate
					else:
						frameTime=frameTime+(int(currentFrameLen)*8)

				if (currentFrameSubType == '0x28' and currentFramePriority == '0'):					
					countBK=countBK + 1
		
				if (currentFrameSubType == '0x28' and currentFramePriority == '1'):
					countBE=countBE + 1
	
				if (currentFrameSubType == '0x28' and currentFramePriority == '5'):
					countVI=countVI + 1
	
				if (currentFrameSubType == '0x28' and currentFramePriority == '6'):
					countVO=countVO + 1
	
				if (currentFrameSubType == '0x20'):
					countNonQoS=countNonQoS + 1
	
		
				currentFrameTime=framesTable[current][0]
				currentFrameLen=framesTable[current][1]
				prevSA = currentFrameSA	
				currentFrameRate=framesTable[current][2]
				currentFrameSubType=framesTable[current][3]	
				currentFrameRA=framesTable[current][4]
				currentFrameTA=framesTable[current][5]	
				currentFrameSA=framesTable[current][6]	
				currentFrameDA=framesTable[current][7]	
				currentFramePriority=framesTable[current][8]	
				currentFrameType=framesTable[current][9]	
				
				

			#check if current frame is a block ack request

			if (currentFrameSubType == '0x18' or currentFrameSubType == '0x19'):
				IFS=ofdmSIFSTime*localFrameCount
				dataFrames=dataFrames+localFrameCount				
				#print "Non-RTS-CTS Case, considering SIFS for",localFrameCount,"Frames"	
			else:
				IFS=bkAIFS*countBK+beAIFS*countBE+viAIFS*countVI+voAIFS*countVO+ofdmDIFSTime*countNonQoS
				dataFrames=dataFrames+countBE+countBK+countVO+countVI+countNonQoS
				#print "Non-RTS-CTS Case, considering bkIFS for",countBK,"Frames"				
				#print "Non-RTS-CTS Case, considering beIFS for",countBE,"Frames"				
				#print "Non-RTS-CTS Case, considering viIFS for",countVI,"Frames"				
				#print "Non-RTS-CTS Case, considering voIFS for",countVO,"Frames"				
				#print "Non-RTS-CTS Case, considering DIFS for",countNonQoS,"Frames"				

			
			totalPreambleTime=localFrameCount*ofdmPreamble
			totalPLCPHeaderTime=localFrameCount*ofdmPLCPHeader
			frameTime=frameTime+IFS+totalPreambleTime+totalPLCPHeaderTime
			#print "Frame Time:",frameTime
			
		elif (float(currentFrameTime) - float(prevFrameTime) <= slot ):
			current=current+1
			if (current < lines):
				#print "Current Frame",current
				prevSA=currentFrameSA
				currentFrameTime=framesTable[current][0]
				currentFrameLen=framesTable[current][1]	
				currentFrameRate=framesTable[current][2]
				currentFrameSubType=framesTable[current][3]	
				currentFrameRA=framesTable[current][4]
				currentFrameTA=framesTable[current][5]	
				currentFrameSA=framesTable[current][6]	
				currentFrameDA=framesTable[current][7]	
				currentFramePriority=framesTable[current][8]	
				currentFrameType=framesTable[current][9]
				#print "Some Other Data Frame",current,currentFrameTime,prevFrameTime,currentFrameSubType
				#readchar.readchar()

	time=time+slot
	ftPercent=100*(float(frameTime)/1000000)

	print time,",",dataFrames,",",frameTime,",",ftPercent
	#if (time >= 785):
	#	print "GrepMe",currentFrameTime,prevFrameTime
	frameTime=0
	ftPercent=0
	prevFrameTime=currentFrameTime
	current=current+1
	dataFrames=0


