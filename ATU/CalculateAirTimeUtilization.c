/*
 tshark -E separator=, -T fields -e frame.time_epoch -e wlan.fc.type_subtype -e prism.did.channel -e wlan.sa -e wlan.da -e wlan.bssid -e wlan.ta -e wlan.ra -e wlan.duration -e prism.did.rate -e wlan.fc.retry -r WR6.pcap > WR6.csv
*/
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#define Max_Frames 10000000
#define SIFS 0.000011

char *Enterprise_Client = "44:6d:57:31:40:6f";
char *Non_Enterprise_Client = "00:00:00:00:00:00";
char *Non_Enterprise_Client1 = "00:04:a3:00:00:07";
char *Non_Enterprise_Client2 = "00:04:a3:00:00:08";
char *Non_Enterprise_Client3 = "00:04:a3:00:00:09";
char *Non_Enterprise_Client4 = "00:04:a3:00:00:10";
char *Non_Enterprise_Client5 = "00:04:a3:00:00:11";
char *Non_Enterprise_Client6 = "00:04:a3:00:00:12";
char *Non_Enterprise_AP = "4c:60";
char *Enterprise_AP = "c4:0a:cb:5c:07:00";

struct PCAP_Data
{
double frame_time_epoch;
char wlan_fc_type_subtype[5];
int wlan_fc_type;
int prism_did_channel;
char wlan_sa[18];
char wlan_da[18];
char wlan_bssid[18];
char wlan_ta[18];
char wlan_ra[18];
double wlan_duration;
int frame_len;
int prism_did_rate;
int wlan_fc_retry;
int wlan_mgt_ds_current_channel;
char wlan_mgt_ssid[33];
int wlan_qos_priority;
}PCAP_DATA_VAL[Max_Frames];


struct FrameType{
int decimal;
char hex[5];
char name[50];
int type;
}FrameTypes[48];

unsigned long framesCount=0;
unsigned long frameTypeCount=0;

void LoadPCAPData(char *pcap);

float calculateFrameTime(struct PCAP_Data frame, struct PCAP_Data prevframe, struct PCAP_Data nextframe);

void LoadPCAPData(char *pcap)
{
unsigned long frame=-1;
FILE *file = fopen(pcap, "r" );
		if (file == NULL)
		{
			printf("\n Unable to read file");
			return;
		}
		char buffer[4095];
		char *token;
		char * end;
		double temp;
		while(fgets(buffer, 4095, file) != NULL)
    		{
		    frame=frame+1;
		    token = strtok(buffer, ",");
		    if (token != NULL)
		    {
		    temp = strtod (token, & end);
			if (end == token)
			PCAP_DATA_VAL[frame].frame_time_epoch = -1;
			else
   		        PCAP_DATA_VAL[frame].frame_time_epoch =  temp;
                    }
   
/*
72500.935500000,158,48,0x1d,1
time,size,datarate,subtype,type
1-time,3-len,6-datarate,7-type_subtype,21-type
#time,type,subtype,datarate,len
*/

		    token = strtok(NULL, ",");
		    if (token != NULL)
   		    PCAP_DATA_VAL[frame].frame_len= atoi(token);		    

		    token = strtok(NULL, ",");
		    if (token != NULL)
   		    PCAP_DATA_VAL[frame].prism_did_rate=atoi(token);
	    
		    token = strtok(NULL, ",");
		    if (token != NULL)
   		    strcpy(PCAP_DATA_VAL[frame].wlan_fc_type_subtype, token);

		    token = strtok(NULL, ",");
		    if (token != NULL)
   		    PCAP_DATA_VAL[frame].wlan_fc_type=atoi(token);

		   

		if (frame > Max_Frames)
		break;
		}
		framesCount=frame;
		fclose(file);
}


void LoadFrameData()
{
unsigned long frameC=-1;
FILE *file = fopen("FrameTypes.csv", "r" );

		if (file == NULL)
		{
			printf("\n Unable to read file");
			return;
		}
		char buffer[4095];
		char *token;
		char * end;
		double temp;

		while(fgets(buffer, 4095, file) != NULL)
    		{
		    frameC=frameC+1;
		    token = strtok(buffer, ",");
		    
			
		    if (token != NULL)
   		    strcpy(FrameTypes[frameC].name, token);

                    token = strtok(NULL, ",");
		    if (token != NULL)
   		    strcpy(FrameTypes[frameC].hex, token);

                    token = strtok(NULL, ",");
		    if (token != NULL)
		    {
		    temp = strtod (token, & end);
			if (end == token)
			FrameTypes[frameC].decimal = -1;
			else
   		        FrameTypes[frameC].decimal =  temp;
                    }
		
		   token = strtok(NULL, ",");
		    if (token != NULL)
		    {
		    temp = strtod (token, & end);
			if (end == token)
			FrameTypes[frameC].type = -1;
			else
   		        FrameTypes[frameC].type =  temp;
                    }

		}

		fclose(file);
frameTypeCount=frameC;
}

float calculateFrameTime(struct PCAP_Data frame, struct PCAP_Data prevframe, struct PCAP_Data nextFrame)
{
float ft = 0.0;
	if (frame.wlan_fc_type == 0)//Management frame
	//ft = 34.0 + 20.0 + ((float)(frame.frame_len * 8)/(((float)frame.prism_did_rate/2)*1000000)); //Management Frame = AIFS[VO] + PLCP + FT
ft = 192 + 20.0 + ((float)(frame.frame_len * 8)/(((float)frame.prism_did_rate/2)*1000000)); //Management Frame = AIFS[VO] + PLCP + FT
	else if (frame.wlan_fc_type == 1 &&  ( (strcmp(prevframe.wlan_fc_type_subtype, "0x1b") == 0 && strcmp(frame.wlan_fc_type_subtype, "0x1c") == 0) || strcmp(frame.wlan_fc_type_subtype, "0x1d") == 0) )
	ft = 16.0 + 20.0 + ((float)(frame.frame_len * 8)/(((float)frame.prism_did_rate/2)*1000000)); //Control Frame, CTS in reply to RTS, ACK
	else if (frame.wlan_fc_type == 1)//Control Frame
	//ft = 43.0 + 20.0 + ((float)(frame.frame_len * 8)/(((float)frame.prism_did_rate/2)*1000000)); //Control Frame, AIFS[BE] + PLCP + FT
ft = 192.0 + 20.0 + ((float)(frame.frame_len * 8)/(((float)frame.prism_did_rate/2)*1000000)); //Control Frame, AIFS[BE] + PLCP + FT
	else if (frame.wlan_fc_type == 2) //Data Frame
	{
	/*	if (strcmp(frame.wlan_fc_type_subtype, "0x28") == 0 && frame.wlan_qos_priority == 0) //QoS data frame, BE AC
		ft = 43.0 + 20.0 + ((float)(frame.frame_len * 8)/(((float)frame.prism_did_rate/2)*1000000)); 
		else if (strcmp(frame.wlan_fc_type_subtype, "0x28") == 0 && frame.wlan_qos_priority == 1) //QoS data frame, BK AC
		ft = 79.0 + 20.0 + ((float)(frame.frame_len * 8)/(((float)frame.prism_did_rate/2)*1000000)); 
		else if (strcmp(frame.wlan_fc_type_subtype, "0x28") == 0 && frame.wlan_qos_priority == 5) //QoS data frame, VI AC
		ft = 34.0 + 20.0 + ((float)(frame.frame_len * 8)/(((float)frame.prism_did_rate/2)*1000000)); 
		else if (strcmp(frame.wlan_fc_type_subtype, "0x28") == 0 && frame.wlan_qos_priority == 6) //QoS data frame, VO AC
		ft = 34.0 + 20.0 + ((float)(frame.frame_len * 8)/(((float)frame.prism_did_rate/2)*1000000)); 
		else
		ft = 50.0 + 192.0 + ((float)(frame.frame_len * 8)/(((float)frame.prism_did_rate/2)*1000000));  // DIFS*/
ft = 50.0 + 192.0 + ((float)(frame.frame_len * 8)/(((float)frame.prism_did_rate/2)*1000000));
	}

ft = ft + (frame.frame_time_epoch - prevframe.frame_time_epoch);
return ft;
}



void CalculateAirtimeUtilization(long slotTime, int lastSlot)
{
int eFrame;	
long nextFrame;
char *success;
int rtsctsFrames=0;
int dataFrames=0;
int ackFrames=0;
char address[18];

double currentTS, nextTS, finalTS;
long nextSlot;
double slot;
long simulationTime = 1800;

dataFrames=0;
rtsctsFrames=0;
ackFrames=0;
eFrame=0;
slot=(float)slotTime;

nextSlot = (lastSlot>0)? lastSlot:1;
currentTS = PCAP_DATA_VAL[eFrame].frame_time_epoch;
nextTS = PCAP_DATA_VAL[eFrame+1].frame_time_epoch;
finalTS = currentTS + slot;


float frameTime = 0.0;
float probeTrafficFrameTime = 0.0;
float dataTrafficFrameTime = 0.0;
float otherTrafficFrameTime = 0.0;
int dispSlot;
	while (eFrame<framesCount-1) 
	{
		
		 if ((nextTS - currentTS) <= slot)
		 {
			float currentFrameTime = 0.0;

			if (eFrame >= 1)
 			currentFrameTime = calculateFrameTime(PCAP_DATA_VAL[eFrame], PCAP_DATA_VAL[eFrame-1], PCAP_DATA_VAL[eFrame+1]); 
			
			
			frameTime = frameTime + currentFrameTime;
			//else
			//frameTime = frameTime + calculateFrameTime(PCAP_DATA_VAL[eFrame], PCAP_DATA_VAL[eFrame], PCAP_DATA_VAL[eFrame+1]); 

			if (strcmp(PCAP_DATA_VAL[eFrame].wlan_fc_type_subtype, "0x04")==0||strcmp(PCAP_DATA_VAL[eFrame].wlan_fc_type_subtype, "0x05")==0)//Probe Traffic
			probeTrafficFrameTime+=currentFrameTime;

			else if ((PCAP_DATA_VAL[eFrame].wlan_fc_type==0) || (PCAP_DATA_VAL[eFrame].wlan_fc_type==1))//Control Traffic or Management Traffic
			otherTrafficFrameTime+=currentFrameTime;

			else if (PCAP_DATA_VAL[eFrame].wlan_fc_type==2)//Data Traffic
			dataTrafficFrameTime+=currentFrameTime;

		 }else{
			//Calculate %
			dispSlot = (slot + nextSlot*slot)/slot;
			
			double percentage = 100 * ((float)frameTime/1000000); //Airtime Utilization %
			double datapercentage = 100 * ((float)dataTrafficFrameTime/1000000); //Airtime Utilization %
			double probepercentage = 100 * ((float)probeTrafficFrameTime/1000000); //Airtime Utilization %
			double otherpercentage = 100 * ((float)otherTrafficFrameTime/1000000); //Airtime Utilization %

			printf("%d,%f,%f,%f,%f\n",dispSlot, percentage, datapercentage, probepercentage, otherpercentage); 

			nextSlot = nextSlot + 1; 
			frameTime = 0;
			dataTrafficFrameTime=0;
			probeTrafficFrameTime=0;
			otherTrafficFrameTime=0;
			currentTS = PCAP_DATA_VAL[eFrame].frame_time_epoch;
		 }
	eFrame++;	
	nextTS = PCAP_DATA_VAL[eFrame].frame_time_epoch;
	}
}



void main( int argc, char *argv[] )
{
	if ( argc != 3 )
    	{        	
        	printf( "usage: %s filename lastSlot\n", argv[0] );
    	}
	else
	{
		LoadPCAPData(argv[1]);
		CalculateAirtimeUtilization(1, atoi(argv[2]));
	}

}

