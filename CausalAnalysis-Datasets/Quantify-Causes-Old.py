#!/usr/bin/python
import sys
import csv
import pdb
import os
import numpy
from numpy import loadtxt
from numpy import genfromtxt

########################################################################################################################################
#################################################****MAC Frame Signatures****##########################################################
#Cause 1 --Periodic: 
#	(S1.1)Precondition: Screen On and State Associated
#	Frame Sequence: Null Data Frame with PS = 1 -> Ack Frame -> Probe Requests with either Empty or Non-Empty SSID -> Null Data Frame with PS = 0 -> Ack Frame
#	(S1.2)Precondition: Screen Off and State Associated
#	Frame Sequence: Null Data Frame or PS-Poll Frame with PS = 1 -> Ack Frame -> Probe Requests with SSID=Associated SSID -> Null Data Frame or PS-Poll Frame with PS = 1 -> Ack Frame
#Cause 2 --Beacon Losses
#	(S2.1)Precondition: Screen Off/On and State Associated
#	Frame Sequence: Null Data Frame with PS = 0 -> No Ack Frame -> Probe Requests with SSID=Associated SSID -> Probe Requests with SSID=EMPTY
#Cause 3 --Signal Strength
#	(S3.1)Precondition: Screen On and State Associated
#	Frame Sequence: Null Data Frame with PS = 1 -> Ack Frame -> Probe Requests with SSID=EMPTY -> Null Data Frame with PS = 0 -> Ack Frame
#	(S3.2)Precondition: Screen Off and State Associated
#	Frame Sequence: Null Data Frame with PS = 1 -> Ack Frame -> Probe Requests with SSID=EMPTY -> Null Data Frame with PS = 1 -> Ack Frame
#Cause 4 --Power Management
#	(S4.1)Precondition: Screen Off and State Associated
#	(S4.1.1)Frame Sequence: Client sends Deauth/Disassoc Frame -> Ack Frame -> Probe Requests with either Empty or Non-Empty SSID 
#	(S4.1.2)Frame Sequence: Client sends PS-Poll Frame with PS = 1 -> Ack Frame -> AP sends Null Data Frame with PS = 0 or RTS Frames -> Probe Requests with SSID=Associated SSID
#	(S4.2)Precondition: Screen transitions from Off to On and State Associated
#	Frame Sequence: PS-Poll frame with PS = 1 -> Ack Frame -> At least one of these (Null Data Frame with PS = 0 -> Ack Frame or
#											 Data Frame with PS = 1 -> Ack Frame or
#											 Null Data Frame with PS = 1 -> Ack Frame) ->
#											 Probe Requests with either Empty or Non-Empty SSID
#Cause 5 --AP Station Mangement
#	(S3.1)Precondition: Screen On/Off and State Associated
#	Frame Sequence: Deauth/Disassoc Frame From AP -> Ack Frame -> Probe Requests with SSID either EMPTY/Non-Empty 
########################################################################################################################################

pcap_csv=sys.argv[1]
beacon_csv=sys.argv[2]
mac=sys.argv[3]
ssids_file=sys.argv[4]
availableSSIDs=""
#clients=sys.argv[2]

if os.path.isfile(pcap_csv) and os.path.getsize(pcap_csv) == 0:
	 sys.exit(0)
	 
if os.path.isfile(beacon_csv) and os.path.getsize(beacon_csv) == 0:
	 sys.exit(0)

if os.path.isfile(ssids_file) and os.path.getsize(ssids_file) == 0:
	 sys.exit(0)		 

frames = open( pcap_csv, "r" ) 
beacons = open( beacon_csv, "r" ) 
ssids = open( ssids_file, "r" ) 

#macs = open(clients, "r")

#clientsTable = []

#for line in macs:
#   clientsTable.append(line)

#clients_count= len(clientsTable)
#clients_details= len(clientsTable[0])


framesTable = []
for line in frames:
   row = line.rstrip().split(',')  
   framesTable.append(row)
#framesTable = genfromtxt(pcap_csv, delimiter=',')

frames_count= len(framesTable)
frame_details= len(framesTable[0])

#print ("Loading Beacons")

beaconsTable = []
for line in beacons:
   row = line.rstrip().split(',')  
   beaconsTable.append(row)
#framesTable = genfromtxt(pcap_csv, delimiter=',')

beacons_count= len(beaconsTable)
beacons_details= len(beaconsTable[0])

#print ("Loading SSIDs")
#ssidTable = []
#for line in ssids:
#   ssidTable.append(line)
   

#ssids_count= len(ssidTable)
#ssid_details= len(ssidTable[0])
ssidreader=csv.reader(ssids,delimiter=',')
for row in ssidreader:
	availableSSIDs=availableSSIDs.join(','.join(row))	

current=-1
mac_state=0 #0-unassociated 1-associated
mac_bssid="EMPTY" #no bssid
mac_ssid="EMPTY"

'''
0. preq pm ssid=empty ssid=non-null ssid=non-null-absent
1. preq bl ssid=empty ssid=non-null ssid=non-null-absent
2. preq s1 ssid=empty ssid=non-null ssid=non-null-absent
3. preq ui ssid=empty ssid=non-null ssid=non-null-absent
preq misc ssid=empty ssid=non-null ssid=non-null-absent
'''
class3Frames="0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2a,0x2b,0x2c,0x2e,0x2f,0x1a,0x18,0x19,0x0d,0x0e"
probeRequestCount = []
probeRequestCount.append([0,0,0])
probeRequestCount.append([0,0,0])
probeRequestCount.append([0,0,0])
probeRequestCount.append([0,0,0])
pRC=0
beacon_ts_prev=-1
beacon_ts_curr=-1
ndf_recvd=0
ndf_ackd=0
disassoc_deauth_recvd=0
disassoc_deauth_ackd=0
waiting_for_probe=-1 #This is used as index for probeRequestCount table, 0 -> pm, 1-> bl, 2->state0, 3->state1, 4->ui/misc
expectedFrameSubType=""

#print ("Processing Frames")
while (current < frames_count-1):
	
	current=current + 1
		
	if (current > frames_count):
		break;
    
	#pdb.set_trace()
	currentFrameTime=framesTable[current][0]
	currentFrameSubType=framesTable[current][1]
	currentFrameSSID=framesTable[current][2]
	currentFrameBSSID=framesTable[current][3]
	currentFramePM=framesTable[current][4]
	currentFrameRA=framesTable[current][5]
	currentFrameTA=framesTable[current][6]
	currentFrameSA=framesTable[current][7]
	currentFrameDA=framesTable[current][8]
	currentFrameReasonCode=framesTable[current][9]
	currentFrameDS=framesTable[current][10]

	if (current>0):
		previous=current-1
		previousFrameTime=framesTable[previous][0]
		previousFrameSubType=framesTable[previous][1]
		previousFrameSSID=framesTable[previous][2]
		previousFrameBSSID=framesTable[previous][3]
		previousFramePM=framesTable[previous][4]
		previousFrameRA=framesTable[previous][5]
		previousFrameTA=framesTable[previous][6]
		previousFrameSA=framesTable[previous][7]
		previousFrameDA=framesTable[previous][8]
		previousFrameReasonCode=framesTable[previous][9]
		previousFrameDS=framesTable[previous][10]
	#print (framesTable[current])
	
	#Reset flags if 1) source of current frame is different from previous frame's MAC and it is different from what we are considering here 2) source of current frame is same from previous frame's MAC but a different than expected frame comes
	'''	
	if (current > 0):
		if (( previousFrameSA != currentFrameSA or previousFrameTA != currentFrameTA) and ( previousFrameSA == mac or previousFrameTA == mac)) or (( previousFrameSA == currentFrameSA or previousFrameTA == currentFrameTA) and ( previousFrameSA == mac or previousFrameTA == mac) and ((currentFrameSubType not in expectedFrameSubType) or (currentFramePM==1 and previousFramePM==1))) :
			ndf_recvd=0
			ndf_ackd=0
			disassoc_deauth_recvd=0
			waiting_for_probe=-1
			expectedFrameSubType=""
	'''

	#State Change U -> A
	if (currentFrameSubType in class3Frames) and ((currentFrameSA == mac) or (currentFrameTA == mac)):
		mac_state=1
		mac_bssid=currentFrameBSSID
	
		#Find SSID of BSSID
		i=0
		while(mac_state == 1 and i < beacons_count and mac_ssid == "EMPTY"):
			cFrameSSID=beaconsTable[i][0]
			cFrameBSSID=beaconsTable[i][1]
			
			if (cFrameBSSID == mac_bssid):
				mac_ssid=cFrameSSID
			i=i+1


	#State Change A -> U
	if (currentFrameSubType=="0x0a" or currentFrameSubType=="0x0c") and ((currentFrameSA == mac) or (currentFrameTA == mac)):
		mac_state=0
		mac_bssid="EMPTY"
		mac_ssid="EMPTY"

	#Next If statements are checking the signature of probe requests due to PM in smartphones
	#Found a NDF from the client in consideration (currentFrameSubType == "0x24" or currentFrameSubType == "0x2c") and 
	#print(currentFramePM , currentFrameSA , currentFrameTA, mac, currentFrameBSSID , mac_bssid)
    
	if (currentFramePM == "1") and ((currentFrameSA == mac) or (currentFrameTA == mac)) and (currentFrameBSSID == mac_bssid): 
		current = current + 1
		#Read current frame
		if (current < frames_count):
			currentFrameTime=framesTable[current][0]
			currentFrameSubType=framesTable[current][1]
			currentFrameSSID=framesTable[current][2]
			currentFrameBSSID=framesTable[current][3]
			currentFramePM=framesTable[current][4]
			currentFrameRA=framesTable[current][5]
			currentFrameTA=framesTable[current][6]
			currentFrameSA=framesTable[current][7]
			currentFrameDA=framesTable[current][8]
			currentFrameReasonCode=framesTable[current][9]
			currentFrameDS=framesTable[current][10]
			
			#Found an ACK
			if (currentFrameSubType == "0x1d" and currentFrameRA == mac):
				current = current + 1
				#Read current frame
				if (current < frames_count):
					currentFrameTime=framesTable[current][0]
					currentFrameSubType=framesTable[current][1]
					currentFrameSSID=framesTable[current][2]
					currentFrameBSSID=framesTable[current][3]
					currentFramePM=framesTable[current][4]
					currentFrameRA=framesTable[current][5]
					currentFrameTA=framesTable[current][6]
					currentFrameSA=framesTable[current][7]
					currentFrameDA=framesTable[current][8]
					currentFrameReasonCode=framesTable[current][9]
					currentFrameDS=framesTable[current][10]
				
					waiting_for_probe = -1
					#Loop through all frames sent SA with PM=0(Awake), we expect probe requests after this
					while (current < frames_count and currentFramePM == "0" and currentFrameSubType != "0x04" and ((currentFrameSA == mac) or (currentFrameTA == mac)) and (currentFrameBSSID == mac_bssid)): 
						#NDF is acknowledged and now found a frame with power save off, spm - smartphone power save
						waiting_for_probe = 0
						current = current + 1
						if current < frames_count:	
							#Read current frame
							currentFrameTime=framesTable[current][0]
							currentFrameSubType=framesTable[current][1]
							currentFrameSSID=framesTable[current][2]
							currentFrameBSSID=framesTable[current][3]
							currentFramePM=framesTable[current][4]
							currentFrameRA=framesTable[current][5]
							currentFrameTA=framesTable[current][6]
							currentFrameSA=framesTable[current][7]
							currentFrameDA=framesTable[current][8]
							currentFrameReasonCode=framesTable[current][9]
							currentFrameDS=framesTable[current][10]
							
					#Count the probe requests
		
					#if no frames found with PM=0, then the following probe requests are due to S1
					#if waiting_for_probe == -1:
					#	waiting_for_probe = 2 #False Sleep
	
					#Count the probe requests
					c0=0
					c1=0
					c2=0
					while (current < frames_count and (currentFrameSA == mac and currentFrameSubType == "0x04" )):	
						#Read current frame
						if current < frames_count:
							currentFrameTime=framesTable[current][0]
							currentFrameSubType=framesTable[current][1]
							currentFrameSSID=framesTable[current][2]
							currentFrameBSSID=framesTable[current][3]
							currentFramePM=framesTable[current][4]
							currentFrameRA=framesTable[current][5]
							currentFrameTA=framesTable[current][6]
							currentFrameSA=framesTable[current][7]
							currentFrameDA=framesTable[current][8]
							currentFrameReasonCode=framesTable[current][9]
							currentFrameDS=framesTable[current][10]
							
							if (currentFrameSSID == "EMPTY" and (currentFrameSA == mac and currentFrameSubType == "0x04" )):
								c0=c0+1
							elif (currentFrameSSID != "EMPTY" and (currentFrameSA == mac and currentFrameSubType == "0x04" )):				
								if ( currentFrameSSID in availableSSIDs): 
									c1=c1+1
								else:
									c2=c2+1
									
							current = current + 1
					current = current - 1 	
					#Low end smartphone's signature sleep, ack, probe request, awake, ack, sleep, ack
					#before deciding the cause check for next frames here
					index=current
					nextPM_FrameTime=-1
					while nextPM_FrameTime==-1 and index<frames_count:
						if framesTable[index][4]=="1" and (framesTable[index][6] == mac or framesTable[index][7] == mac ):
							nextPM_FrameTime=framesTable[index][0]
						else:
							index=index+1
					
					if float(nextPM_FrameTime) - float(currentFrameTime) <= 15.0:
							waiting_for_probe = 0
					else:
							waiting_for_probe = 2
							
					probeRequestCount[waiting_for_probe][0]=probeRequestCount[waiting_for_probe][0]+c0
					probeRequestCount[waiting_for_probe][1]=probeRequestCount[waiting_for_probe][1]+c1
					probeRequestCount[waiting_for_probe][2]=probeRequestCount[waiting_for_probe][2]+c2
					
					waiting_for_probe=-1				
					
		
	#Found an disassoc or deauth #True Sleep of laptop
	if ((currentFrameSubType == "0x0a" or currentFrameSubType == "0x0c") and (currentFrameReasonCode == "0x0003")):
		#Ack may or not be received here-we should consider both cases
		#read frames for ACKs
		current = current + 1
		#Read current frame
		currentFrameTime=framesTable[current][0]
		currentFrameSubType=framesTable[current][1]
		currentFrameSSID=framesTable[current][2]
		currentFrameBSSID=framesTable[current][3]
		currentFramePM=framesTable[current][4]
		currentFrameRA=framesTable[current][5]
		currentFrameTA=framesTable[current][6]
		currentFrameSA=framesTable[current][7]
		currentFrameDA=framesTable[current][8]
		currentFrameReasonCode=framesTable[current][9]
		currentFrameDS=framesTable[current][10]
		waiting_for_probe = 0

		#below loop is to skip all ACKs to Disassoc and Deauth frame
		while (current < frames_count and (currentFrameRA == mac) and currentFrameSubType == "0x1d"): 
			current = current + 1
			#Read current frame
			if current < frames_count:
				currentFrameTime=framesTable[current][0]
				currentFrameSubType=framesTable[current][1]
				currentFrameSSID=framesTable[current][2]
				currentFrameBSSID=framesTable[current][3]
				currentFramePM=framesTable[current][4]
				currentFrameRA=framesTable[current][5]
				currentFrameTA=framesTable[current][6]
				currentFrameSA=framesTable[current][7]
				currentFrameDA=framesTable[current][8]
				currentFrameReasonCode=framesTable[current][9]
				currentFrameDS=framesTable[current][10]
		
		#Now we should see probe requests
		#Count the probe requests
		while (current < frames_count and (currentFrameSA == mac and currentFrameSubType == "0x04" )):	
			#Restore Frame Details to current frame
			currentFrameTime=framesTable[current][0]
			currentFrameSubType=framesTable[current][1]
			currentFrameSSID=framesTable[current][2]
			currentFrameBSSID=framesTable[current][3]
			currentFramePM=framesTable[current][4]
			currentFrameRA=framesTable[current][5]
			currentFrameTA=framesTable[current][6]
			currentFrameSA=framesTable[current][7]
			currentFrameDA=framesTable[current][8]
			currentFrameReasonCode=framesTable[current][9]
			currentFrameDS=framesTable[current][10]
			if (currentFrameSSID == "EMPTY" and (currentFrameSA == mac and currentFrameSubType == "0x04" )):
				probeRequestCount[waiting_for_probe][0]=probeRequestCount[waiting_for_probe][0]+1
			elif (currentFrameSSID != "EMPTY" and (currentFrameSA == mac and currentFrameSubType == "0x04" )):
				
				if ( currentFrameSSID in availableSSIDs): 
					probeRequestCount[waiting_for_probe][1]=probeRequestCount[waiting_for_probe][1]+1			
				else:
					probeRequestCount[waiting_for_probe][2]=probeRequestCount[waiting_for_probe][2]+1
			current = current + 1
		current = current - 1 	
		waiting_for_probe=-1				
		
	#Found a probe
	if (currentFrameSA == mac and currentFrameSubType == "0x04" ):
		#This will find signatures for BL, S1, and UI
		#Beacon Loss
		#pdb.set_trace()
		if (mac_state == 1 and currentFrameSSID==mac_ssid): #Associated and between a beacon interval
			
			temp=current
			countUnicast=0
			while (countUnicast <=3 and temp < frames_count and (currentFrameSA == mac and currentFrameSubType == "0x04" )):
				if(currentFrameSSID==mac_ssid and currentFrameSubType == "0x04" and currentFrameSA == mac):
					countUnicast=countUnicast + 1
				currentFrameSubType=framesTable[temp][1]
				currentFrameSSID=framesTable[temp][2]
				currentFrameSA=framesTable[temp][7]
				temp=temp + 1

			if (countUnicast >= 3): #Beacon Loss Detected
				waiting_for_probe=1
			else:
				waiting_for_probe=2

			#Restore Frame Details to current frame
			currentFrameTime=framesTable[current][0]
			currentFrameSubType=framesTable[current][1]
			currentFrameSSID=framesTable[current][2]
			currentFrameBSSID=framesTable[current][3]
			currentFramePM=framesTable[current][4]
			currentFrameRA=framesTable[current][5]
			currentFrameTA=framesTable[current][6]
			currentFrameSA=framesTable[current][7]
			currentFrameDA=framesTable[current][8]
			currentFrameReasonCode=framesTable[current][9]
			currentFrameDS=framesTable[current][10]
	
			#Count the probe requests
			while (current < frames_count and (currentFrameSA == mac and currentFrameSubType == "0x04" )):	
				#Restore Frame Details to current frame
				currentFrameTime=framesTable[current][0]
				currentFrameSubType=framesTable[current][1]
				currentFrameSSID=framesTable[current][2]
				currentFrameBSSID=framesTable[current][3]
				currentFramePM=framesTable[current][4]
				currentFrameRA=framesTable[current][5]
				currentFrameTA=framesTable[current][6]
				currentFrameSA=framesTable[current][7]
				currentFrameDA=framesTable[current][8]
				currentFrameReasonCode=framesTable[current][9]
				currentFrameDS=framesTable[current][10]
				if (currentFrameSSID == "EMPTY" and (currentFrameSA == mac and currentFrameSubType == "0x04" )):
					probeRequestCount[waiting_for_probe][0]=probeRequestCount[waiting_for_probe][0]+1
				elif (currentFrameSSID != "EMPTY" and (currentFrameSA == mac and currentFrameSubType == "0x04" )):
					
					if ( currentFrameSSID in availableSSIDs): 
						probeRequestCount[waiting_for_probe][1]=probeRequestCount[waiting_for_probe][1]+1			
					else:
						probeRequestCount[waiting_for_probe][2]=probeRequestCount[waiting_for_probe][2]+1
				current = current + 1
			current = current - 1 	
			waiting_for_probe=-1				
				

		else: #UnAssociated
			waiting_for_probe=3
			if (currentFrameSSID == "EMPTY"):
				probeRequestCount[waiting_for_probe][0]=probeRequestCount[waiting_for_probe][0]+1
			else:
				
				if ( currentFrameSSID in availableSSIDs): 
					probeRequestCount[waiting_for_probe][1]=probeRequestCount[waiting_for_probe][1]+1
				else:
					probeRequestCount[waiting_for_probe][2]=probeRequestCount[waiting_for_probe][2]+1
			waiting_for_probe=-1
				
			
			
print (mac, probeRequestCount)



